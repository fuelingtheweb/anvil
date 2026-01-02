db.create () {
    echo "Creating database: $1"
    mysql -u root -h 127.0.0.1 -e "create database $1"
}
pg.create () {
    createdb $1
}
db.drop () {
    echo "Dropping database: $1"
    mysql -u root -h 127.0.0.1 -e "drop database $1"
}
db.export () {
    echo "Exporting database: $1"
    mysqldump -u root -h 127.0.0.1 $1 > ~/Downloads/$1.sql
}
db.refresh () {
    folder=${PWD##*/}
    name=$(echo "$folder" | awk '{print tolower($0)}')

    # mysql -uroot -h 127.0.0.1 -Nse 'SHOW TABLES' simplypickem | while read table; do mysql -uroot -h 127.0.0.1 -e "SET FOREIGN_KEY_CHECKS = 0; DROP TABLE IF EXISTS \`$table\`; SET FOREIGN_KEY_CHECKS = 1;" simplypickem; done
    echo "Refreshing database: $name"
    db.drop $name
    db.create $name
    db.import $name
}
db.import () {
    local name=$1
    local file=""
    local pathsToCheck=(
        "${HOME}/Downloads/${name}.dump"
        "${HOME}/Downloads/${name}.sql"
        "./__resources/db/${name}.dump"
        "./__resources/db/${name}.sql"
    )

    for filepath in "${pathsToCheck[@]}"; do
        if [ -f "$filepath" ]; then
            file="$filepath"
            break
        fi
    done

    if [ "$2" ]; then
        file=$2
    fi

    if ! command -v mysql >/dev/null 2>&1; then
        echo "Error: 'mysql' command not found in PATH. Please ensure MySQL is installed and available." >&2
        return 1
    fi

    if [ ! -f "$file" ]; then
        echo "Error: SQL file not found: $file" >&2
        return 1
    fi

    echo "Importing database: ${name} from file: ${file}"

    # Use 'command' to avoid shell function overrides, and avoid shell exit on error
    command mysql -u root -h 127.0.0.1 "$name" < "$file"
    local exit_status=$?
    if [ $exit_status -ne 0 ]; then
        echo "Error: MySQL import failed with exit code $exit_status" >&2
        return $exit_status
    fi
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
