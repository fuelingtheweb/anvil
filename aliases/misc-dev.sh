alias duster='vendor/bin/duster'
alias dust='duster fix'
alias dusty='duster lint'
alias dustd='duster fix --dirty'

dep.upgrade () {
    git branch -D ntm/upgrade-dependencies
    git checkout -b ntm/upgrade-dependencies
    composer upgrade
    git add composer.*
    git commit -m 'Upgrade composer dependencies'
    npm upgrade
    git commit -am 'Upgrade npm dependencies'
    git push --set-upstream origin ntm/upgrade-dependencies
    gh pr create --title "Upgrade dependencies" --web
}

benchmark () {
    local iterations=$1
    local url=$2

    echo "✨ Preloading to warm cache"
    curl -s -o /dev/null "$url"

    echo "⏳ Benchmarking ${url} (${iterations} iterations)"

    local totaltime=0.0
    for run in $(seq 1 $iterations); do
        local time=$(curl $url -s -o /dev/null -w "%{time_total}")
        totaltime=$(echo "$totaltime" + "$time" | bc)
    done

    local avgtimeMs=$(echo "scale=1; 1000*${totaltime}/${iterations}" | bc)

    echo "✅ ${avgtimeMs} ms"
}
