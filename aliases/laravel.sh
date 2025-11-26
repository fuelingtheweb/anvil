alias lv="laravel"
alias lz="laravel-zero"
alias artisan="php artisan"
alias a="php artisan"
alias log:empty="echo '' > storage/logs/laravel.log"
alias elf="log.empty"
alias cpe="cp .env.example .env"
ac () {
    artisan optimize:clear
    composer dump-autoload
}
alias er="envoy run"
alias edy="envoy run deploy"
alias ers="envoy run reseed"
lsu () {
    ci
    cpe
    akg
    ni
    nd
}
alias ah="artisan help"
alias av="artisan --version"
alias lds="artisan dump-server"
alias dsk="artisan dusk"
alias tnk="artisan tinker"
alias as="artisan serve"
alias aom="artisan operations:make"
alias aos="artisan operations:show"
alias aop="artisan operations:process"
alias ahz="artisan horizon"
alias ahc="artisan horizon:clear"
alias aqc="artisan queue:clear"
alias aqw="artisan queue:work"
alias akg="artisan key:generate"
alias arl="artisan route:list"
alias avp="artisan vendor:publish"
alias aeg="artisan event:generate"
alias amg="artisan migrate"
alias amgfr="artisan migrate:fresh"
alias amgrb="artisan migrate:rollback"
alias amgfs="artisan migrate:fresh --seed"
alias adbs="artisan db:seed"
alias adbw="artisan db:wipe"
alias adbbc="artisan debugbar:clear"
alias asv="artisan scrap:view"
alias ad="artisan dusk"
alias adm="artisan dusk:make"
alias atp="artisan test --parallel --stop-on-failure"
alias aac="artisan assets:compile"
alias aar="artisan assets:release"
alias arcc="artisan responsecache:clear"
aee () {
    env:encrypt --env=production --force --key="$1"
}
aed () {
    env:decrypt --env=production --force --key="$1"
}
alias am="artisan make"
alias amcmd="artisan make:command"
alias amcom="artisan make:component"
alias amc="artisan make:controller"
alias amca="artisan make:cast"
alias amen="artisan make:enum"
alias ame="artisan make:event"
alias amexc="artisan make:exception"
alias amexp="artisan make:export"
alias ami="artisan make:import"
alias amj="artisan make:job"
alias aml="artisan make:listener"
alias amma="artisan make:mail"
alias ammi="artisan make:middleware"
alias ammg="artisan make:migration --fullpath"
alias ammd="artisan make:model"
alias amn="artisan make:notification"
alias amo="artisan make:observer"
alias ampo="artisan make:policy"
alias ampr="artisan make:provider"
alias amrq="artisan make:request"
alias amrs="artisan make:resource"
alias amrl="artisan make:rule"
alias ams="artisan make:seeder"
alias amt="artisan make:test"
alias amtu="artisan make:test --unit"
alias amv="artisan make:view"
alias amw="artisan make:livewire"
amf () {
    NAME="${1}Factory"
    artisan make:factory --model="$1" $NAME
}
ammam () {
    artisan make:mail "$1" --markdown "$2"
}
ammgc () {
    ammg "create_${1}_table" --create "$1"
}