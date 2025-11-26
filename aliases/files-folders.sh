# Show human friendly numbers and colors
# alias ls='ls -GhFp'
# alias ll='ls -FGlAhp'
alias ls='eza -1F'
alias lsa='eza -a1F'
alias l='eza -alF --time-style iso --color=always'
alias ll='eza -alF --time-style iso --color=always'
alias lll='eza -alghHF --git --time-style long-iso --color=always'
alias lm='ll --sort modified --reverse --git-ignore'
alias lmh='lm | head'
alias lsg='ll | grep -i'

alias cpr='cp -r'

# Changing Directories
alias cdp='cd -' # Go back to previous directory
alias rmr="rm -R" # Remove directory and anything within directory
mkcd () {
    mkdir -p -- "$1" &&
    cd -P -- "$1"
}
alias mdc='mkcd'
alias tch='touch'
alias cdc='cd $_'
alias d='cd'

cdr () {
    control=$(find-up node_modules)

    if [ -d "$control" ]; then
        cd "${control%node_modules}"
    else
        echo 'Root project not found.'
    fi
}

alias organize='ll | fpp -ko -ai'
alias mvf='mv $F'
