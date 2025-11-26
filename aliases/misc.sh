alias cat='bat'
alias ping='prettyping --nolegend'
alias fnd='command fd -c always'
alias du="ncdu --color dark -rr -x --si --exclude .git --exclude node_modules --exclude vendor"
alias nn='nnn'
alias help='tldr'
agif () {
    ag $1 -G $2
}
alias sdi='sed -i ""'
alias cvl='csvlook'
alias _='sudo'
alias w='which'
alias m="cd ~/ && /bin/cat ${HOME}/Dev/Anvil/custom/ascii/welcome.honk.txt"
alias dld="cd ${HOME}/Downloads"
alias dcs="cd ${HOME}/Documents"
alias dv="cd ${HOME}/Dev"
alias bc="bc -l -q" # Run Calculator
alias hi="history | less +G"
alias vf="vifm"
alias pn="pianokeys && pianobar" # Start Pianobar for Pandora
alias q="exit"
alias untar="tar -zxvf"
alias prinfo="lpstat -p -d" # List printers
alias pr="lpr" # Print file
alias psa="ps aux"
alias psg="ps aux | grep "
alias psr='ps aux | grep ruby'
alias less='less -r'
alias tlf='tail -f'
# alias l='less'
alias screen='TERM=screen screen'
alias gz='tar -zcvf' # Zippin
alias ka9='killall -9'
alias k9='kill -9'
alias kp='kill -9'
alias pwdc="pwd | tr -d '\n' | pbcopy && echo 'pwd copied to clipboard'"
# alias duc='du -hc -d=1 *'

alias o='open'
o. () {
    open .
}

alias rm='trash'
alias pls='sudo $(fc -ln -1)'
file.hide () {
    defaults write com.apple.finder AppleShowAllFiles NO
    killall Finder /System/Library/CoreServices/Finder.app
}
files.show () {
    defaults write com.apple.finder AppleShowAllFiles YES
    killall Finder /System/Library/CoreServices/Finder.app
}
alias ydl='youtube-dl'
alias ke="code ${HOME}/.config/karabiner.edn"
alias ab="php ${HOME}/Dev/Anvil/artisan build:aliases && source $ANVIL/aliases/index.sh"
alias kb="php ${HOME}/Dev/Anvil/artisan build:karabiner && goku"
alias kbw='gokuw'
alias anb='kb && ab'
alias cleaninstall="${ANVIL}/CleanInstall/start.sh"
pdf.combine () {
    /usr/local/bin/gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=merged.pdf
}
pdf.compress () {
    /usr/local/bin/gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dPDFSETTINGS=/screen -sOutputFile=small.pdf # ebook | screen
}
php.memory () {
    php -r "echo ini_get('memory_limit').PHP_EOL;"
}

tidy () {
    date=$(date +%Y-%m-%d)
    folder="${HOME}/Documents/Tidy/${date}"

    mkdir -p "$folder"

    mv "${HOME}/Downloads/*" "$folder"

    open "${HOME}/Downloads"
    open "$folder"
}

catc () {
    cat $1 | pbcopy
}

alias ipc='dig +short myip.opendns.com @resolver1.opendns.com | pbcopy'

webpc() {
    if [ -f "$1" ]; then
        webp.convert "$@"
    else
        webp.convert-all "$@"
    fi
}

webp.convert-all() {
    for file in *.(gif|jpg|jpeg|png|webp); do
        webp.convert "$file" "$@"
    done
}

webp.convert() {
    outputPath="${HOME}/Downloads/webp"

    if ! [[ -d "$outputPath" ]]; then
        md "$outputPath"
    fi

    file=$1
    width=$2
    height=$3

    if ! [ "$height" ]; then
        height="0"
    fi


    filename="${file%.*}"
    input="$file"
    output="${outputPath}/${filename}.webp"

    echo "Converting ${input} to ${output}"

    if [ "$width" ]; then
        cwebp -pass 1 -m 6 -mt -q 100 -resize "$width" "$height" -progress "$input" -o "$output"
    else
        cwebp -pass 1 -m 6 -mt -q 100 -progress "$input" -o "$output"
    fi

    # cwebp -pass 1 -m 6 -mt -q 90 -resize "$width" "$height" -progress "$input" -o "$output"
}

alias wpc='webpc'
