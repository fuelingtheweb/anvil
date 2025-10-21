function db:create () { mysql -uroot -e "create database $1" }
function db:create.57 () { mysql -uroot --host=127.0.0.1 --port=33067 -e "create database $1" }
function pg:create () { createdb $1 }
function db:drop () { mysql -uroot -e "drop database $1" }
function db:drop.57 () { mysql -uroot --host=127.0.0.1 --port=33067 -e "drop database $1" }
function db:export () { mysqldump -u root $1 > ~/Downloads/$1.sql }
function db:export.57 () { mysqldump -uroot --host=127.0.0.1 --port=33067 $1 > ~/Downloads/$1.sql }
function db:refresh () {
    folder=${PWD##*/}
    name=$(echo "$folder" | awk '{print tolower($0)}')

    db:drop $name
    db:create $name
    db:import $name ./__resources/db/$name.sql
}
function db:refresh.dump () {
    folder=${PWD##*/}
    name=$(echo "$folder" | awk '{print tolower($0)}')

    db:drop $name
    db:create $name
    db:import $name ./__resources/db/$name.dump
}
function db:import () {
    local file=~/Downloads/$1.sql

    if [ "$2" ]; then
        file=$2
    fi

    mysql -u root $1 < $file
}
function db:refresh.57 () {
    local file=~/Downloads/$1.sql

    if [ "$2" ]; then
        file=$2
    fi

    db:drop:57 $1
    db:create:57 $1
    db:import:dump:57 $1 $file
}
function db:import.57 () {
    local file=~/Downloads/$1.sql

    if [ "$2" ]; then
        file=$2
    fi

    mysql -uroot --host=127.0.0.1 --port=33067 $1 < $file
}
function db:import.dump () { mysql -u root $1 < ~/Downloads/$1.dump }
function db:import.dump.57 () { mysql -uroot --host=127.0.0.1 --port=33067 $1 < ~/Downloads/$1.dump }
function pg:import () { psql -f ~/Downloads/$1.sql $1 -U root -h localhost -W }
function db:dump-all () {
    cd ~/Downloads
    for DB in $(mysql -e 'show databases' -s --skip-column-names); do
        echo $DB
        if [ $DB != 'information_schema' ] && [ $DB != 'performance_schema' ]; then
            mysqldump $DB > "$DB.sql";
        fi
    done
}
alias db='mycli'
alias dbc='db:create'
alias dbr='db:refresh'
alias dbi='db:import'
alias dbe='db:export'
alias dbc57='db:create:57'
alias dbr57='db:refresh:57'
alias dbi57='db:import:57'
alias dbe57='db:export:57'
function ipgdb () {
    # $1 = path/to/file, $2 = db name
    psql -f $1 $2 -U nathan -h localhost -W
}
function rpgdb () {
    # $1 = path/to/file, $2 = db name
    # psql -f $1 $2 -U nathan -h localhost -W
    # pg_restore -h host -p port -d db_name archive_file.dump
    pg_restore -d $2 $1
}
function pg:export () {
    # $1 = db name
    pg_dump -U nathan -W -F t $1 > $HOME/Downloads/$1.tar
}
