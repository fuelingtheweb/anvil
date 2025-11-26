db.create () {
    mysql -uroot -e "create database $1"
}
pg.create () {
    createdb $1
}
db.drop () {
    mysql -uroot -e "drop database $1"
}
db.export () {
    mysqldump -u root $1 > ~/Downloads/$1.sql
}
db.refresh () {
    folder=${PWD##*/}
    name=$(echo "$folder" | awk '{print tolower($0)}')

    db_drop $name
    db_create $name
    db_import $name ./__resources/db/$name.sql
}
db.refresh_dump () {
    folder=${PWD##*/}
    name=$(echo "$folder" | awk '{print tolower($0)}')

    db_drop $name
    db_create $name
    db_import $name ./__resources/db/$name.dump
}
db.import () {
    local file=~/Downloads/$1.sql

    if [ "$2" ]; then
        file=$2
    fi

    mysql -u root $1 < $file
}
db.import_dump () {
    mysql -u root $1 < ~/Downloads/$1.dump
}
pg.import () {
    psql -f ~/Downloads/$1.sql $1 -U root -h localhost -W
}
db.dump_all() {
    cd ~/Downloads
    local databases=$(mysql -e 'show databases' -s --skip-column-names)

    for DB in $databases; do
        echo "$DB"
        if [[ "$DB" != 'information_schema' && "$DB" != 'performance_schema' ]]; then
            mysqldump $DB > "$DB.sql";
        fi
    done
}
alias db='mycli'
alias dbc='db.create'
alias dbr='db.refresh'
alias dbi='db.import'
alias dbe='db.export'
ipgdb () {
    # $1 = path/to/file, $2 = db name
    psql -f $1 $2 -U nathan -h localhost -W
}

pg.restore () {
    local database=''
    local filepath=''
    local host='localhost'
    local port='5433'
    local user='root'

    # Parse options first
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--host)
                host="$2" && shift 2;;
            -p|--port)
                port="$2" && shift 2;;
            -u|--user)
                user="$2" && shift 2;;
            -h|--help)
                echo "Usage: pg16:restore <database> [filepath] [-host <host>] [-port <port>] [-user <user>]"
                echo "If filepath is omitted, defaults to ~/Downloads/<database>.dump"
                return 0;;
            -*)
                echo "Unknown option: $1" >&2
                echo "Use -h for help" >&2
                return 1;;
            *)
                # This is a positional argument
                if [[ -z "$database" ]]; then
                    database="$1"
                elif [[ -z "$filepath" ]]; then
                    filepath="$1"
                else
                    echo "Error: Too many positional arguments" >&2
                    return 1
                fi
                shift;;
        esac
    done

    # Check required parameter
    if [[ -z "$database" ]]; then
        echo "Error: database name is required" >&2
        echo "Usage: pg16:restore <database> [filepath] [options...]" >&2
        return 1
    fi

    # Set default filepath if not provided
    if [[ -z "$filepath" ]]; then
        filepath="$HOME/Downloads/${database}.dump"
    fi

    # Check if dump file exists
    if [[ ! -f "$filepath" ]]; then
        echo "Error: Dump file not found: ${filepath}" >&2
        return 1
    fi

    echo "Restoring database '${database}' from '${filepath}'"
    echo "Target: ${user}@${host}:${port}"

    /Users/Shared/Herd/services/postgresql/18/bin/pg_restore \
        --host="${host}" \
        --port="${port}" \
        --username="${user}" \
        --dbname="${database}" \
        --clean --if-exists --no-owner --verbose \
        "${filepath}"
}

pg.export () {
    # $1 = db name
    pg_dump -U nathan -W -F t $1 > $HOME/Downloads/$1.tar
}
