success 'Installing Anvil.'

source $src/brew.sh

# Installed ohmyzsh manually
# Make sure ohmyzsh agnoster theme is copied over
git clone git@github.com:ohmyzsh/ohmyzsh.git $OHMYZSH
git clone git@github.com:romkatv/powerlevel10k.git $OHMYZSH/custom/themes/powerlevel10k
git clone git@github.com:zdharma/fast-syntax-highlighting.git $OHMYZSH/custom/plugins/fast-syntax-highlighting
git clone git@github.com:zsh-users/zsh-autosuggestions.git $OHMYZSH/custom/plugins/zsh-autosuggestions
git clone git@github.com:zsh-users/zsh-syntax-highlighting.git $OHMYZSH/custom/plugins/zsh-syntax-highlighting

# Install and setup lazygit
# brew install lazygit
# Open lazygit
# ln -sf ~/Dev/Anvil/options/lazygit.yml ~/Library/Application\ Support/lazygit/config.yml
# Set zoom size in vscode to 3

# Download from github and install ttf fonts
git clone git@github.com:tonsky/FiraCode.git $HOME/FiraCode
cp $HOME/FiraCode/distr/ttf/* $HOME/Library/Fonts/
rm -rf $HOME/FiraCode

dotfiles=(
    .gitignore
    .zshrc # *
    .my.cnf
    .npmrc
    .phpmd.xml
    .php_cs
    .bash_profile
    .hammerspoon # *
    .ctags
    .mackup
    .mackup.cfg
    .prettierrc
)

for file in "${dotfiles[@]}"; do
    trash "$HOME/$file"
    ln -sf "$ANVIL/dotfiles/$file" "$HOME/$file"
done

ln -sf "$HOME/Dev/Anvil/dotfiles/.zshrc" "$HOME/.zshrc"
ln -sf "$HOME/Dev/Anvil/dotfiles/.hammerspoon" "$HOME/.hammerspoon"

trash $ANVIL/custom
trash $ANVIL/aliases/custom
trash $ANVIL/dotfiles/.hammerspoon/config/custom
ln -s $HOME/Dropbox/Ftw/fuelingzsh-custom/custom $ANVIL/custom
ln -s $HOME/Dropbox/Ftw/fuelingzsh-custom/aliases/custom $ANVIL/aliases/custom
ln -s $HOME/Dropbox/Ftw/fuelingzsh-custom/dotfiles/.hammerspoon/config/custom $ANVIL/dotfiles/.hammerspoon/config/custom
trash $HOME/.config/karabiner.edn
mkdir $HOME/.config # *
$ANVIL=$HOME/Dev/Anvil
ln -sf $HOME/Dev/Anvil/karabiner/karabiner.edn $HOME/.config/karabiner.edn # *
trash $HOME/.warprc
ln -s $ANVIL/custom/dotfiles/.warprc $HOME/.warprc
ln -s $ANVIL/custom/espanso $HOME/Library/Preferences/espanso
cp $ANVIL/options/fonts/Droid+Sans+Mono+Awesome.ttf $HOME/Library/Fonts/Droid+Sans+Mono+Awesome.ttf
touch $HOME/.hushlogin

espanso register
espanso start

# needs to happen after opening karabiner elements and ensuring "Default" profile is available
goku

info 'Open Karabiner.'
open -a 'Karabiner-Elements.app'
info 'Confirm profile is named Default.'
pause

info 'Open Hammerspoon.'
open -a 'Hammerspoon.app'
pause

info 'Confirm Karabiner and Hammerspoon are working.'
pause

source $src/osx.sh

success 'Changing default shell to zsh. Restart computer, open Warp, and run cleaninstall.'
sudo dscl . -create /Users/$USER UserShell `which zsh`
chsh -s `which zsh`
