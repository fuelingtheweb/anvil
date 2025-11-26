wp.cd () {
    if [ -d "$1" ]; then
        cd "$1"
    elif [ -d "wordpress/$1" ]; then
        cd "wordpress/$1"
    fi
}
alias wpt='wp.cd wp-content/themes'
alias wpp='wp.cd wp-content/plugins'

alias wpv='wp --version'

wppc () {
    wp post create --post_type=page --post_status=publish --post_title="$1"
}
