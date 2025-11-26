# Xdebug
xdebug.disable () {
    echo "" > $(php --ini | grep xdebug)
}
xdebug.enable () {
    command cat $(php --ini | grep xdebug).back > $(php --ini | grep xdebug)
}
alias xdd='xdebug.disable'
alias xde='xdebug.enable'

alias t='ts'

alias ts='td --stop-on-defect'
alias ta='td'
alias tf='td --stop-on-defect --filter'
alias tfa='td --filter'

alias td='phpunit.run --testdox'
alias ti='phpunit.run --stop-on-defect'
alias tia='phpunit.run'

alias tcc='rm .phpunit.result.cache'

tm () {
    local i=0

    while true; do
        i=$((i+1))

        echo "Running test $i"

        t "$@" || break;
    done
}

tfm () {
    local i=0

    while true; do
        i=$((i+1))

        echo "Running test $i"

        tf "$@" || break;
    done
}

alias tge='t --exclude-group'
alias tg='t --group'
alias tpg='tp --group'
alias tdg='td --group'

# Code Coverage
tc () {
    xdebug.enable
    t --coverage-html ./tests/coverage "$@"
    xdebug.disable
}

tpc () {
    xdebug.enable
    tp --coverage-html ./tests/coverage "$@"
    xdebug.disable
}

tdc () {
    xdebug.enable
    td --coverage-html ./tests/coverage "$@"
    xdebug.disable
}

alias tco='br ./tests/coverage/index.html'

phpunit.run () {
    local suffix=(--dont-report-useless-tests --order-by=defects $@)
    # suffix=(--cache-result --order-by=defects $@)

    # clear

    if [ -f vendor/bin/phpunit ]; then
        vendor/bin/phpunit $@
    else
        phpunit $@
    fi
}
