ZSH=$HOME/.oh-my-zsh
ANVIL=$HOME/Dev/Anvil
OPTIONS=$ANVIL/options
ALIASES=$ANVIL/aliases
CUSTOM=$ANVIL/custom
ZSH_DISABLE_COMPFIX="true"
DISABLE_AUTO_UPDATE="true"

ZSH_THEME="ftw-agnoster"

plugins=(
    history-substring-search
    urltools
)
source $ZSH/oh-my-zsh.sh

# https://volta.sh/
export VOLTA_HOME=$HOME/.volta
export KEYTIMEOUT=1
export VISUAL=code
export EDITOR=code
export FPP_EDITOR=code
export NNN_DE_FILE_MANAGER=open
export CLICOLOR_FORCE='yes'
export PATH=/Applications/Docker.app/Contents/Resources/bin:$VOLTA_HOME/bin:$ANVIL/bin:$HOME/.composer/vendor/bin:/usr/local/sbin:$PATH
# export PATH=$VOLTA_HOME/bin:$ANVIL/bin:$HOME/.composer/vendor/bin:$HOME/.yarn/bin:$HOME/bin:/usr/local/sbin:$PATH
source $OPTIONS/misc.sh
source $ALIASES/index.sh

if [[ -a $CUSTOM/localrc.sh ]]; then
    source $CUSTOM/localrc.sh
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# export NVM_DIR="$HOME/.nvm"
# [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
# [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# export NODE_OPTIONS=--openssl-legacy-provider

# if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

PROMPT="${PROMPT}"$'\n'

# Herd injected PHP binary.
export PATH="$HOME/Library/Application Support/Herd/bin/":$PATH

# Herd MySQL
export PATH="/Users/Shared/Herd/services/mysql/8.0.36/bin:$PATH"

# Added by Windsurf
export PATH="$HOME/.codeium/windsurf/bin:$PATH"

# Herd injected PHP 8.4 configuration.
export HERD_PHP_84_INI_SCAN_DIR="/Users/nmorgan/Library/Application Support/Herd/config/php/84/"

# Herd injected PHP 8.3 configuration.
export HERD_PHP_83_INI_SCAN_DIR="/Users/nmorgan/Library/Application Support/Herd/config/php/83/"
export PATH="$HOME/.local/bin:$PATH"


# Herd injected PHP 8.5 configuration.
export HERD_PHP_85_INI_SCAN_DIR="/Users/nmorgan/Library/Application Support/Herd/config/php/85/"
export PATH="$HOME/.local/bin:$PATH"
