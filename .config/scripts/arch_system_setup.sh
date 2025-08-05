echo "==== SETUP ===="

# Enable multilib
echo "Enabling multilib..."
sudo sed -i '/#\[multilib\]/{N;s/#Include/Include/;s/#\[multilib\]/[multilib]/}' /etc/pacman.conf
sudo pacman -Sy
sudo pacman -Fy
echo "Enabling multilib done."

# Tools
echo "Installing required tools"
sudo pacman -S --needed --noconfirm base-devel git alacritty fzf ripgrep tmux zsh pass neovim eza easyeffects noto-fonts-cjk noto-fonts-emoji man-db aws-cli zip unzip fcitx5 fcitx5-configtool steam wtype docker docker-compose github-cli tealdeer wikiman html2text
echo "Installing required tools done."

# tldr pages
tldr --update

# Paru (AUR)
echo "Installing AUR package manager (paru)"
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
echo "Installing AUR package manager (paru) done."

# AUR Deps
echo "Installing AUR dependencies..."
paru -S asdf-vm spotify
echo "Installing AUR dependencies done."

# Remove local golang installation
sudo pacman -R go

# asdf managed tools
echo "asdf setup for (go, rust, zig)..."
asdf plugin add golang
asdf plugin add zig
asdf plugin add rust
asdf install golang latest
asdf install rust latest
asdf install zig latest
echo "asdf setup for (go, rust, zig) done."

# Full Desktop Environment: https://github.com/end-4/dots-hyprland
bash <(curl -s "https://end-4.github.io/dots-hyprland-wiki/setup.sh")

# Replace parts of the base setup (will be pulled from my dotfiles)
rm -rf $HOME/.config/quickshell
rm -rf $HOME/.config/hypr

# Dotfiles
echo "Installing dotfiles..."
git clone --bare https://github.com/sleiphir/dotfiles.git $HOME/.dotfiles
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME submodule update --init --recursive
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME config --local status.showUntrackedFiles no
echo "Installing dotfiles done."

# Fix suspend/wakeup issues
sudo systemctl enable nvidia-suspend.service
sudo systemctl enable nvidia-hibernate.service
sudo systemctl enable nvidia-resume.service

# Use nvim config while root
sudo ln -s $HOME/.config/nvim /root/.config/nvim

echo "==== DONE ===="

