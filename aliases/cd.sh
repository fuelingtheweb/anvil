function ftw_repeat() {
    echo $(printf "%.0s$1" $(seq 1 $2))
}

function ftw_init_cd_aliases() {
    for i in $(seq 1 $1); do
        local alias_commas=$(ftw_repeat , $i)
        local cd_command="cd $(ftw_repeat ../ $i)"
        alias ",$alias_commas"="$cd_command && ll"
    done
}

ftw_init_cd_aliases 10

alias ..='cd ..'
