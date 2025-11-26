#!/usr/bin/env bash

success "Installing Homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew tap federico-terzi/espanso
brew tap homebrew/cask-drivers

formulas=(
    ack
    autojump
    bat
    csvkit
    diff-so-fancy
    eza # *
    fasd
    fd
    fpp
    fzf
    fzf # *used for git.checkout
    tmux # *used for git.checkout
    git
    gh # *
    highlight
    httpie
    hub
    ncdu
    nnn
    prettyping
    terminal-notifier
    tesseract
    tldr
    trash # *
    vim
    z
    mas
    php-cs-fixer
    phpmd
    composer # *
    yqrashawn/goku/goku # *
    mackup
    volta # *
    zsh # *
)

for formula in "${formulas[@]}"; do
    formula_name=$( echo "$formula" | awk '{print $1}' )
    if brew list "$formula_name" > /dev/null 2>&1; then
        echo "$formula_name already installed... skipping."
    else
        brew install "$formula"
    fi
done

# After the install, setup fzf
echo -e "\\n\\nRunning fzf install script..."
echo "=============================="
/usr/local/opt/fzf/install --all --no-bash --no-fish

casks=(
    alfred
    appcleaner
    betterzip
    cursorcerer
    hammerspoon # *
    vlc
    bartender
    discord
    karabiner-elements # *
    tinkerwell
    spotify
    beardedspice
    ray
    raycast # *
    espanso # *
    warp # *
)

for cask in "${casks[@]}"; do
    cask_name=$( echo "$cask" | awk '{print $1}' )
    if brew list --cask "$cask_name" > /dev/null 2>&1; then
        echo "$cask_name already installed... skipping."
    else
        brew install --cask "$cask"
    fi
done
