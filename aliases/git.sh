alias g='git'

alias ghh="gh dash --config ${HOME}/Dev/Anvil/options/gh-dash.yml"

alias gg='lazygit'

alias ga='git add'
alias gah='git add --help'
alias gaa='git add -A'
alias gap='git add -p'

alias gb='git.branch.list'
alias gbh='git branch --help'
alias gba='git branch -av'
alias gbc='git.branch.current | pbcopy'
alias gbr='git.branch.rename'
alias gbd='git.branch.delete'
alias gbdf='git.branch.force-delete'

alias gc='git.commit'
alias gch='git commit --help'
alias gcm='git commit --amend --no-edit'
alias gcme='git commit --amend'
alias gcnv='git commit --no-verify -m'

alias gcp='git cherry-pick'
alias gcph='git cherry-pick --help'
alias gcpn='git cherry-pick -n'
alias gcpc='git cherry-pick --continue'

alias gcl='git clone --recurse-submodules'
alias gci='git check-ignore -v'
alias gcc='git.copy-commits'
alias gccf='git.copy-commits-full'

alias gd='git diff'
alias gdh='git diff --help'
alias gds='git diff --staged'

alias gf='git fetch'
alias gfp='git fetch --prune'

# Git Flow Commands
alias gfi='git flow init'
alias gfid='git flow init -d'
alias gfhs='git flow hotfix start'
alias gfhf='git flow hotfix finish'
alias gfco='git flow feature checkout'
alias gffs='git flow feature start'
alias gffp='git flow feature publish'
alias gfff='git flow feature finish'
alias gfrs='git flow release start'
alias gfrf='git flow release finish'

alias gin='git init'
alias gig='code .gitignore'

alias gl='git.log'

alias gm='git.merge'
gmm () {
    git merge $(git.master-branch)
}
alias gmd='git merge develop'
alias gmc='git merge --continue'
alias gma='git merge --abort'

alias gms='git solo'
alias gmw='git mob'
alias gml='git mob --list'
alias gmeco='code ~/.git-coauthors'
alias gmsco='git suggest-coauthors'

alias go='git.checkout'
alias goh='git checkout --help'
alias gon='git.branch.new'
alias gop='git checkout -'
alias goa='git.checkout.include-all'
alias gom='git.checkout-master'
alias god='git checkout develop'
alias goml='git.checkout-master && git pull'
alias godl='git checkout develop && git pull'

alias gps='git push'
alias gpsn='git push --no-verify'
alias gpst='git push origin --tags'
alias gpsu='git.push-set-upstream'
alias gpl='git pull'

alias gpr='git.pull-request'

alias pr='gh pr'
alias prc='gh pr checkout'
alias pro='gh pr view --web'

alias gr='git.rebase'
grm () {
    git rebase $(git.master-branch)
}
alias grd='git rebase develop'
alias grc='git rebase --continue'
alias gra='git rebase --abort'

alias grs='git reset'
alias grsh='git reset --hard'

alias grmv='git remote -v'
alias grmr='git remote rm'
alias grma='git remote add'
alias grmsu='git remote set-url'

alias gs='git.status'
alias gsf='git.status.fuzzy'
alias gsh='git show'
alias gshs='git.show.summary'
alias gss='git.status.stats'

alias gsm='git submodule'
alias gsmi='git submodule init'
alias gsmu='git submodule update'

alias gst='git stash'
alias gstm='git stash -m'
alias gstu='git stash -u'
alias gstum='git stash -u -m'
alias gstsm='git stash --staged -m'
alias gstl='git.stash.list'
alias gstc='git stash clear'
alias gstp='git.stash.pop'
alias gsta='git.stash.apply'
alias gsts='git.stash.show'
alias gstsp='git.stash.show-patch'
alias gstd='git.stash.drop'

alias gt='git tag'
alias gtt='git tag | tail'
gtc () {
    echo -n $(git tag | tail -1) | pbcopy
}

alias guc='git.uncommit'
alias gus='git.unstage'
alias gum='git.update-master'

alias nah='git reset --hard; git clean -df;'

cdu () {
    cd $(git rev-parse --show-toplevel)
}

git.is-in-repo () {
  git rev-parse HEAD > /dev/null 2>&1
}

git.checkout () {
  if [ "$1" ]; then
    git checkout "$@"
  else
    local branches branch
    branches=$(git branch --no-color | grep -v HEAD | grep -v '^* ' | grep -v '^  main' | grep -v '^  master' | grep -v '^  develop') &&
    branch=$(echo "$branches" |
             fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
    git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
  fi
}

git.checkout.include-all () {
  local branches branch
  branches=$(git branch --all --no-color | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

git.branch.exists () {
    local branch=${1}
    local existed_in_local=$(git branch --list ${branch})

    if [[ -z ${existed_in_local} ]]; then
        echo 0
    else
        echo 1
    fi
}

git.branch.current () {
    echo -n $(git rev-parse --abbrev-ref HEAD)
}

git.branch.list () {
    git for-each-ref --sort=committerdate refs/heads/ --format="%(authordate:short) %(color:red)%(objectname:short) %(color:yellow)%(refname:short)%(color:reset) (%(color:green)%(committerdate:relative)%(color:reset))"
}

git.branch.new () {
    local branch_name="${1// /-}"
    git checkout -b "$branch_name"
}

git.branch.rename () {
    local branchName=$1
    if [[ -z $branchName ]]; then
        branchName="nmorgan/$(git.branch.current)"
    fi

    git branch -m $branchName
}

git.branch.delete () {
  local branches branch
  branches=$(git branch -vv --no-color | grep -v '^* ' | grep -v '^  main' | grep -v '^  master' | grep -v '^  develop') &&
  branch=$(echo "$branches" | fzf +m) &&
  git branch -d $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}

git.branch.force-delete () {
  local branches branch
  branches=$(git branch -vv --no-color | grep -v '^* ' | grep -v '^  main' | grep -v '^  master' | grep -v '^  develop') &&
  branch=$(echo "$branches" | fzf +m) &&
  git branch -D $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}

git.checkout-master () {
    git checkout $(git.master-branch)
}

git.commit () {
    if [ "$1" ]; then
        git commit -m "$1"
    else
        git commit
    fi
}

git.copy-commits () {
    git log --no-merges --reverse --pretty=format:'- %s' $(git.master-branch).. | pbcopy
}

git.copy-commits-full () {
    git log --no-merges --reverse --pretty=format:'%h - %s - %cn' $(git.master-branch).. | pbcopy
}

git.log () {
    git log --graph --date=short
}

git.master-branch () {
    if [[ $(git.branch.exists 'main') == 1 && $(git.branch.exists 'master') == 0 ]]; then
        echo 'main'
    else
        echo 'master'
    fi
}

git.merge () {
  if [ "$1" ]; then
    git merge "$1"
  else
    local branches branch
    branches=$(git branch --no-color | grep -v HEAD) &&
    branch=$(echo "$branches" |
             fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
    git merge $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
  fi
}

git.pull-request () {
    local branchName=$(git.branch.current)
    if [[ $branchName != $'ntm/'* && $branchName != $'nmorgan/'* ]]; then
        echo 'Prepend branch name with ntm/ or nmorgan/ before proceeding.'
        return
    fi

    git.push-set-upstream

    if [ $? -eq 0 ]; then
        git.copy-commits
        gh pr create --web
        # githubUrl=`git remote -v | awk '/fetch/{print $2}' | sed -Ee 's#(git@|git://)#http://#' -e 's@com:@com/@' -e 's%\.git$%%'`;
        # prUrl="$githubUrl/compare/$(git.master-branch)...$(git.branch.current)?expand=1"
        # "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" "$prUrl" --profile-directory="Default"
    else
        echo 'failed to push commits and open a pull request.';
    fi
}

git.push-set-upstream () {
    git push --set-upstream origin $(git.branch.current)
}

git.rebase () {
  if [ "$1" ]; then
    git rebase "$1"
  else
    local branches branch
    branches=$(git branch --no-color | grep -v HEAD) &&
    branch=$(echo "$branches" |
             fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
    git rebase $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
  fi
}

git.status.with-summary () {
    git.status
    echo ""
    git.show.summary
}

git.status () {
    git status -sb
    git.status.stats
}

git.status.stats () {
    modifiedStats=$(git --no-pager diff --shortstat)
    stagedStats=$(git --no-pager diff --shortstat --staged)

    echo "\e[31mModified $modifiedStats\e[0m"
    echo "\e[33mStaged   $stagedStats\e[0m"
}

git.show.summary () {
    Red='\033[0;31m'; Colour_Off='\033[0m'; Cyan='\033[0;36m';
    git show --pretty="format:%C(blue)%ah %C(bold magenta)%s%Creset%n%C(yellow)%h %C(blue)%an%C(yellow)%d%Creset" --date=relative --no-patch
    stats=$(git show --format="" --shortstat)
    echo "\e[32m$stats\e[0m"
    # git diff $BRANCH --name-status|awk "{print \"$Red\" \$1 \"\t\" \"$Cyan\" \$2 \"$Colour_Off\"}"

}

git.status.fuzzy () {
    # "Nothing to see here, move along"
    git.is-in-repo || return

    local cmd="${FZF_CTRL_T_COMMAND:-"command git status --porcelain"}"

    eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" fzf -m "$@" | while (read -r item) {
        code $(printf '%q ' "$item" | cut -d " " -f 2)
    }
}

git.stash.list () {
    git stash list --stat --format='%n%C(yellow)%gd%Creset %C(blue)(%ch):%Creset %C(magenta)%gs%Creset'
}

git.stash.pop () {
    if [ "$1" ]; then
        git stash pop stash@{"$1"}
    else
        git stash pop
    fi
}

git.stash.apply () {
    if [ "$1" ]; then
        git stash apply stash@{$1}
    else
        git stash apply
    fi
}

git.stash.show () {
    if [ "$1" ]; then
        git stash show -u stash@{$1}
    else
        git stash show -u
    fi
}

git.stash.show-patch () {
    if [ "$1" ]; then
        git stash show -p stash@{$1}
    else
        git stash show -p
    fi
}

git.stash.drop () {
    if [ "$1" ]; then
        git stash drop stash@{$1}
    else
        git stash drop
    fi
}

git.update-master () {
    local branch=$(git.branch.current)
    git.checkout-master
    git pull
    git checkout $branch
}

git.uncommit () {
    git reset --soft HEAD\^
}

git.unstage () {
    git reset HEAD
}

lint.tlint () {
    git status --porcelain | grep '??' | cut -f2 -d' ' | xargs -L1 ~/Dev/Anvil/bin/tlint-run.sh
    git status --porcelain | grep ' M ' | cut -f3 -d' ' | xargs -L1 ~/Dev/Anvil/bin/tlint-run.sh
}
