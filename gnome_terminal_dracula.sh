#!/usr/bin/env bash

set -e

echo "▶ Atualizando pacotes e instalando dependências..."
sudo apt update
sudo apt install -y zsh git curl wget unzip dconf-cli

echo "▶ Definindo Zsh como shell padrão..."
chsh -s "$(which zsh)"

echo "▶ Instalando Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "▶ Instalando Powerlevel10k..."
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

echo "▶ Instalando plugins zsh-autosuggestions e syntax-highlighting..."
git clone https://github.com/zsh-users/zsh-autosuggestions.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

echo "▶ Instalando Fira Code Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
cd "$FONT_DIR"
if ! fc-list | grep -qi "FiraCode Nerd Font"; then
  wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
  unzip -o FiraCode.zip
  rm FiraCode.zip
  fc-cache -fv
fi

echo "▶ Aplicando Dracula theme no GNOME Terminal..."
TEMP_DIR=$(mktemp -d)
git clone https://github.com/dracula/gnome-terminal.git "$TEMP_DIR"
cd "$TEMP_DIR"
chmod +x install.sh
./install.sh
cd ~
rm -rf "$TEMP_DIR"

echo "▶ Gerando .zshrc configurado..."

cat > "$HOME/.zshrc" <<'EOF'
# =====================================================
# POWERLEVEL10K – INSTANT PROMPT
# =====================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =====================================================
# OH MY ZSH
# =====================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# =====================================================
# ZSH SYNTAX HIGHLIGHTING (FAST)
# =====================================================
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# =====================================================
# DRACULA SYNTAX COLORS
# =====================================================
ZSH_HIGHLIGHT_STYLES[command]='fg=#50fa7b'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#8be9fd'
ZSH_HIGHLIGHT_STYLES[function]='fg=#50fa7b'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#50fa7b'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#ff79c6'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#8be9fd'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#ff79c6'
ZSH_HIGHLIGHT_STYLES[path]='fg=#f8f8f2'
ZSH_HIGHLIGHT_STYLES[path_approx]='fg=#ffb86c'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#ffb86c'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#bd93f9'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#ffb86c'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#ffb86c'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#f1fa8c'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#f1fa8c'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#f1fa8c'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ff5555'

# =====================================================
# POWERLEVEL10K CONFIG
# =====================================================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

echo "✔ Setup completo! Reinicie o terminal e escolha a fonte FiraCode Nerd Font."
