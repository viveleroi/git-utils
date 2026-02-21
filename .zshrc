alias co="git checkout"
alias br='git branch'
alias gs='git status'
alias gc='git commit'
alias fu='git fetch upstream'
alias rum='git rebase upstream/main'
alias fo='git fetch'
alias rom='git rebase origin/main'
alias gsub='git submodule update --init --recursive'
alias gpop='git reset --soft HEAD~1'
alias amend='git add . && git commit --amend'
alias amendnv='git add . && git commit --amend --no-verify'
alias log='git log'
alias log1='git log --oneline'
alias squash='git rebase --autosquash main'

function git_branch_name()
{
  branch=$(git symbolic-ref HEAD 2> /dev/null | awk 'BEGIN{FS="/"} {print $NF}')
  if [[ $branch == "" ]];
  then
    :
  else
    echo '- (%F{blue}'$branch'%f)'
  fi
}

setopt prompt_subst

prompt='%2/ $(git_branch_name) > '

# Checkout main branch, pull+rebase with upstream, and push to your local
# Usage:
# $ rmain
function rmain() {
  echo "git checkout main"
  git checkout main

  echo "git pull --rebase upstream main"
  git pull --rebase upstream main

  echo "git push origin main"
  git push origin main
}

# Interactive rebase with X commits off head
# Usage:
# $ squash (number from head)
function squashn() {
 local NUMBER=${1:-2}

 echo "git rebase -i HEAD~$NUMBER"
 git rebase -i HEAD~$NUMBER
}

# Rebase an upstream feature branch
# Usage:
# $ rfeat (branch: current, or name)
function rfeat() {
  local BRANCH
  if [ -z "$1" ]; then
    BRANCH=$(git rev-parse --abbrev-ref HEAD) #
  else
    BRANCH=$1
  fi

  echo "git fetch upstream"
  git fetch upstream

  echo "git checkout $BRANCH"
  git checkout "$BRANCH"

  echo "git reset --hard upstream/$BRANCH"
  git reset --hard "upstream/$BRANCH"

  echo "git rebase upstream/main"
  git rebase upstream/main
}

# Pulls and rebases the remote branch
# Usage:
# $ gpull
# $ gpull (remote: origin, or name) (branch: current, or name)
function gpull() {
  local REMOTE=${1:-'origin'}
  local BRANCH
  if [ -z "$2" ]; then
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
  else
    BRANCH=$2
  fi

  echo "git pull --rebase $REMOTE $BRANCH"
  git pull --rebase "$REMOTE" "$BRANCH"
}

# Pushes a local branch to a remote
# Usage:
# $ gpush
# $ gpush (remote: origin, or name) (branch: current, or name)
function gpush() {
  local REMOTE=${1:-'origin'}
  local BRANCH
  if [ -z "$2" ]; then
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
  else
    BRANCH=$2
  fi

  echo "git push $REMOTE $BRANCH"
  git push "$REMOTE" "$BRANCH"
}

# Force-pushes a local branch to a remote
# Usage:
# $ gfpush
# $ gfpush (remote: origin, or name) (branch: current, or name)
function gfpush() {
  local REMOTE=${1:-'origin'}
  local BRANCH
  if [ -z "$2" ]; then
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
  else
    BRANCH=$2
  fi

  echo "git push -f $REMOTE $BRANCH"
  git push -f "$REMOTE" "$BRANCH"
}

# Deletes a branch both locally and from a remote.
# Usage:
# $ branchd (branch)
# $ branchd (branch) (remote: origin, or name)
function branchd() {
  local BRANCH=$1
  local REMOTE=${2:-'origin'}

  if [ -z "$BRANCH" ]; then
    echo "Missing branch name"
    return 1
  fi

  echo "git branch -d $BRANCH"
  git branch -d "$BRANCH"

  echo "git push $REMOTE :$BRANCH"
  git push "$REMOTE" ":$BRANCH"
}

# Makes a dev/fixup commit if there are no commits on the branch, otherwise makes a fixup to the first commit on the branch. 
# Usage:
# $ dev
function dev() {
  git add .
  local FIXUP_HASH=$(git log main..HEAD --reverse --format="%H" | head -n 1)
  if [[ -z "$FIXUP_HASH" ]]; then
    git commit -m "dev"
  else
    git commit --fixup "$FIXUP_HASH"
  fi
}

# Makes a WIP commit if there are no commits on the branch, otherwise makes a fixup to the first commit on the branch, without running pre-commit hooks.
# Usage:
# $ wip
function wip() {
  git add .
  local FIXUP_HASH=$(git log main..HEAD --reverse --format="%H" | head -n 1)
  if [[ -z "$FIXUP_HASH" ]]; then
    git commit -m "wip" --no-verify
  else
    git commit --no-verify --fixup "$FIXUP_HASH"
  fi
}

# Resets the current branch to upstream/main and cherry-picks the latest commit back on top.
# Useful when old commits no longer match and rebase would conflict.
# Usage:
# $ replant
function replant() {
  local BRANCH=$(git rev-parse --abbrev-ref HEAD)

  if [[ "$BRANCH" == "main" ]]; then
    echo "Cannot replant on main"
    return 1
  fi

  local COMMIT=$(git rev-parse HEAD)
  echo "Saving commit $COMMIT"

  echo "git fetch upstream"
  git fetch upstream

  echo "git reset --hard upstream/main"
  git reset --hard upstream/main

  echo "git cherry-pick $COMMIT"
  git cherry-pick "$COMMIT"
}