import Service from 'resource:///com/github/Aylur/ags/service.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';

import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import Soup from 'gi://Soup?version=3.0';
import { fileExists } from '../modules/.miscutils/files.js';

function guessModelLogo(model) {
    if (model.includes("llama")) return "ollama-symbolic";
    if (model.includes("gemma")) return "google-gemini-symbolic";
    if (model.includes("deepseek")) return "deepseek-symbolic";
    if (/^phi\d*:/i.test(model)) return "microsoft-symbolic";
    return "ollama-symbolic";
}

function guessModelName(model) {
    const replaced = model.replace(/-/g, ' ').replace(/:/g, ' ');
    const words = replaced.split(' ');
    words[words.length - 1] = words[words.length - 1].replace(/(\d+)b$/, (_, num) => `${num}B`)
    words[words.length - 1] = `[${words[words.length - 1]}]`; // Surround the last word with square brackets
    const result = words.join(' ');
    return result.charAt(0).toUpperCase() + result.slice(1); // Capitalize the first letter
}

const PROVIDERS = Object.assign({
    "openrouter": {
        "name": "Gemini 2.0 Flash",
        "logo_name": "google-gemini-symbolic",
        "description": getString('Somewhat good for coding but super cheap'),
        "base_url": "https://openrouter.ai/api/v1/chat/completions",
        "key_get_url": "https://openrouter.ai/keys",
        "requires_key": true,
        "key_file": "openrouter_key.txt",
        "model": "google/gemini-2.0-flash-001",
    },
    "openrouter_2": {
        "name": "DeepSeek v3 (free)",
        "logo_name": "deepseek-symbolic",
        "description": getString('685B parameters for free?'),
        "base_url": "https://openrouter.ai/api/v1/chat/completions",
        "key_get_url": "https://openrouter.ai/keys",
        "requires_key": true,
        "key_file": "openrouter_key.txt",
        "model": "deepseek/deepseek-chat-v3-0324:free",
    },
    "openrouter_3": {
        "name": "Claude 3.7 Sonnet",
        "logo_name": "anthropic-symbolic",
        "description": getString('The best Anthropic model to date'),
        "base_url": "https://openrouter.ai/api/v1/chat/completions",
        "key_get_url": "https://openrouter.ai/keys",
        "requires_key": true,
        "key_file": "openrouter_key.txt",
        "model": "deepseek/deepseek-chat-v3-0324:free",
    },
    "openai": {
        "name": "OpenAI - GPT-3.5",
        "logo_name": "openai-symbolic",
        "description": getString('Official OpenAI API.\nPricing: Free for the first $5 or 3 months, whichever is less.'),
        "base_url": "https://api.openai.com/v1/chat/completions",
        "key_get_url": "https://platform.openai.com/api-keys",
        "requires_key": true,
        "key_file": "openai_key.txt",
        "model": "gpt-3.5-turbo",
    },
}, userOptions.ai.extraGptModels)

const installedOllamaModels = JSON.parse(
    Utils.exec(`${App.configDir}/scripts/ai/show-installed-ollama-models.sh`))
    || [];
installedOllamaModels.forEach(model => {
    const providerKey = `ollama_${model}`; // Generate a unique key for each model
    PROVIDERS[providerKey] = {
        name: `Ollama - ${guessModelName(model)}`,
        logo_name: guessModelLogo(model),
        description: `Ollama model: ${model}`,
        base_url: 'http://localhost:11434/v1/chat/completions',
        key_get_url: "",
        requires_key: false,
        key_file: "ollama_key.txt",
        model: `${model}`
    };
});

// Custom prompt
const initMessages =
    [
        { role: "user", content: "Adjust your tone to sound more casual and personable while maintaining clarity. Do not be overly enthusiastic. Try to express yourself in a few words like long term friends would via text messages." },
        { role: "assistant", content: "alright", },
        { role: "user", content: "I need help", },
        { role: "assistant", content: "what's up?", },
        { role: "user", content: "my C program won't compile", },
        { role: "assistant", content: "what does it says?", },
        { role: "user", content: "`gcc not command not found`", },
        { role: "assistant", content: "hmm maybe try `sudo pacman -S gcc` and try again", },
        { role: "user", content: "that worked thanks dude", },
        { role: "assistant", content: "np", },
    ];

Utils.exec(`mkdir -p ${GLib.get_user_state_dir()}/ags/user/ai`);

class GPTMessage extends Service {
    static {
        Service.register(this,
            {
                'delta': ['string'],
            },
            {
                'content': ['string'],
                'thinking': ['boolean'],
                'done': ['boolean'],
            });
    }

    _role = '';
    _content = '';
    _hasReasoningContent = false;
    _parsedReasoningContent = false;
    _lastContentLength = 0;
    _thinking;
    _done = false;

    constructor(role, content, thinking = true, done = false) {
        super();
        this._role = role;
        this._hasReasoningContent = false;
        this._parsedReasoningContent = false;
        this._content = content;
        this._thinking = thinking;
        this._done = done;
    }

    get done() { return this._done }
    set done(isDone) { this._done = isDone; this.notify('done') }

    get role() { return this._role }
    set role(role) { this._role = role; this.emit('changed') }

    get hasReasoningContent() { return this._hasReasoningContent }
    set hasReasoningContent(value) {
        this._hasReasoningContent = value;
        this.emit('changed')
    }

    get parsedReasoningContent() { return this._parsedReasoningContent }
    set parsedReasoningContent(value) {
        this._parsedReasoningContent = value;
        this.emit('changed')
    }

    get content() { return this._content }
    set content(content) {
        this._content = content;
        if (this._content.length - this._lastContentLength >= userOptions.ai.charsEachUpdate) {
            this.notify('content')
            this.emit('changed')
            this._lastContentLength = this._content.length;
        }
    }

    get label() { return this._parserState.parsed + this._parserState.stack.join('') }

    get thinking() { return this._thinking }
    set thinking(value) {
        this._thinking = value;
        this.notify('thinking')
        this.emit('changed')
    }

    addDelta(delta) {
        if (delta == null) return;
        if (this.thinking) {
            this.thinking = false;
            this.content = delta;
        }
        else {
            this.content += delta;
        }
        this.emit('delta', delta);
    }
}

class GPTService extends Service {
    static {
        Service.register(this, {
            'initialized': [],
            'clear': [],
            'newMsg': ['int'],
            'hasKey': ['boolean'],
            'providerChanged': [],
        });
    }

    _assistantPrompt = true;
    _currentProvider = PROVIDERS[userOptions.ai.defaultGPTProvider] ? userOptions.ai.defaultGPTProvider : Object.keys(PROVIDERS)[0];
    _requestCount = 0;
    _temperature = userOptions.ai.defaultTemperature;
    _messages = [];
    _key = '';
    _key_file_location = `${GLib.get_user_state_dir()}/ags/user/ai/${PROVIDERS[this._currentProvider]['key_file']}`;
    _url = GLib.Uri.parse(PROVIDERS[this._currentProvider]['base_url'], GLib.UriFlags.NONE);

    _decoder = new TextDecoder();

    _initChecks() {
        this._key_file_location = `${GLib.get_user_state_dir()}/ags/user/ai/${PROVIDERS[this._currentProvider]['key_file']}`;
        if (fileExists(this._key_file_location)) this._key = Utils.readFile(this._key_file_location).trim();
        else this.emit('hasKey', false);
        this._url = GLib.Uri.parse(PROVIDERS[this._currentProvider]['base_url'], GLib.UriFlags.NONE);
    }

    constructor() {
        super();
        this._initChecks();

        if (this._assistantPrompt) this._messages = [...initMessages];
        else this._messages = [];

        this.emit('initialized');
    }

    get modelName() { return PROVIDERS[this._currentProvider]['model'] }
    get getKeyUrl() { return PROVIDERS[this._currentProvider]['key_get_url'] }
    get providerID() { return this._currentProvider }
    set providerID(value) {
        this._currentProvider = value;
        this.emit('providerChanged');
        this._initChecks();
    }
    get providers() { return PROVIDERS }

    get keyPath() { return this._key_file_location }
    get key() { return this._key }
    set key(keyValue) {
        this._key = keyValue;
        Utils.writeFile(this._key, this._key_file_location)
            .then(this.emit('hasKey', true))
            .catch(print);
    }

    get temperature() { return this._temperature }
    set temperature(value) { this._temperature = value; }

    get messages() { return this._messages }
    get lastMessage() { return this._messages[this._messages.length - 1] }

    clear() {
        if (this._assistantPrompt)
            this._messages = [...initMessages];
        else
            this._messages = [];
        this.emit('clear');
    }

    get assistantPrompt() { return this._assistantPrompt; }
    set assistantPrompt(value) {
        this._assistantPrompt = value;
        if (value) this._messages = [...initMessages];
        else this._messages = [];
    }

    readResponse(stream, aiResponse) {
        aiResponse.thinking = false;
        stream.read_line_async(
            0, null,
            (stream, res) => {
                if (!stream) return;
                const [bytes] = stream.read_line_finish(res);
                const line = this._decoder.decode(bytes);
                if (line && line != '') {
                    let data = line.substr(6);
                    if (data == '[DONE]') return;
                    try {
                        const result = JSON.parse(data);
                        if (result.choices[0].finish_reason === 'stop') {
                            aiResponse.done = true;
                            return;
                        }

                        // aiResponse.addDelta(result.choices[0].delta.content);
                        if (!result.choices[0].delta.content && result.choices[0].delta.reasoning_content) {
                            if (!aiResponse.hasReasoningContent) {
                                aiResponse.hasReasoningContent = true;
                                aiResponse.addDelta(`<think>\n${result.choices[0].delta.reasoning_content}`);
                            }
                            else {
                                aiResponse.addDelta(`<think>\n${result.choices[0].delta.reasoning_content}`);
                            }
                        }
                        else {
                            if (aiResponse.hasReasoningContent) {
                                aiResponse.parsedReasoningContent = true;
                                aiResponse.addDelta(`\n</think>\n`);
                            }
                            aiResponse.addDelta(result.choices[0].delta.content);
                        }
                    }
                    catch {
                        //aiResponse.addDelta(line + '\n');
                    }
                }
                this.readResponse(stream, aiResponse);
            });
    }

    addMessage(role, message) {
        this._messages.push(new GPTMessage(role, message));
        this.emit('newMsg', this._messages.length - 1);
    }

    send(msg) {
        this._messages.push(new GPTMessage('user', msg, false, true));
        this.emit('newMsg', this._messages.length - 1);
        const aiResponse = new GPTMessage('assistant', '', true, false)

        const body = {
            "model": PROVIDERS[this._currentProvider]['model'],
            "messages": this._messages.map(msg => { let m = { role: msg.role, content: msg.content }; return m; }),
            "temperature": this._temperature,
            "stream": true,
            "keep_alive": userOptions.ai.keepAlive,
        };
        // console.log(body);
        const proxyResolver = new Gio.SimpleProxyResolver({ 'default-proxy': userOptions.ai.proxyUrl });
        const session = new Soup.Session({ 'proxy-resolver': proxyResolver });
        const message = new Soup.Message({
            method: 'POST',
            uri: this._url,
        });
        message.request_headers.append('Authorization', `Bearer ${this._key}`);
        message.set_request_body_from_bytes('application/json', new GLib.Bytes(JSON.stringify(body)));

        session.send_async(message, GLib.DEFAULT_PRIORITY, null, (_, result) => {
            const stream = session.send_finish(result);
            this.readResponse(new Gio.DataInputStream({
                close_base_stream: true,
                base_stream: stream
            }), aiResponse);
        });
        this._messages.push(aiResponse);
        this.emit('newMsg', this._messages.length - 1);
    }
}

export default new GPTService();













