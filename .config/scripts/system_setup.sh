echo "==== SETUP ===="
# Tools
echo "Installing required tools"
sudo pacman -S -needed base-devel git alacritty fzf ripgrep tmux zsh pass neovim eza easyeffects noto-fonts-emoji man-db aws-cli
echo "Installing required tools done."

# Paru (AUR)
echo "Installing AUR package manager (paru)"
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
echo "Installing AUR package manager (paru) done."

# AUR Deps
echo "Installing AUR dependencies..."
paru -S asdf-vm
echo "Installing AUR dependencies done."

# asdf managed tools
echo "asdf setup for (go, rust, zig)..."
asdf plugin add golang
asdf plugin add zig
asdf plugin add rust
asdf install golang latest
asdf install rust latest
asdf install zig latest
asdf set golang latest
asdf set rust latest
asdf set zig latest
echo "asdf setup for (go, rust, zig) done."

# Full Desktop Environment: https://github.com/end-4/dots-hyprland
bash <(curl -s "https://end-4.github.io/dots-hyprland-wiki/setup.sh")

# Replace parts of the base setup (will be pulled from my dotfiles)
rm -rf .config/ags
rm -rf .config/hypr

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

# Force performance mode (fix flickering issues)
echo "options nvidia NVreg_RegistryDwords=\"PowerMizerEnable=0x1; PerfLevelSrc=0x2222; PowerMizerLevel=0x3; PowerMizerDefault=0x3; PowerMizerDefaultAC=0x3\"" > nvidia.conf
sudo mv nvidia.conf /etc/modprobe.d
sudo chown root:root /etc/modprobe.d/nvidia.conf

echo "==== DONE ===="

