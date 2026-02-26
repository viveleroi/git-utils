alias co='git checkout'
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
alias dev='git add . && git commit -m "dev(dev): Dev"'
alias wip='git add . && git commit -m "wip" --no-verify'

PS1='\h:\W$(__git_ps1 "(%s)") \u\$ '
RED="\[\033[0;31m\]"
GREEN="\[\033[0;32m\]"
YELLOW="\[\033[0;33m\]"
BLUE="\[\033[0;34m\]"
PURPLE="\[\033[0;35m\]"
TEAL="\[\033[0;36m\]"
GRAY="\[\033[0;37m\]"
WHITE="\[\033[0;38m\]"
PS1="$TEAL\h: $GRAY\W$GREEN \$(__git_ps1 '(%s)')$WHITE \$ "

# Checkout main branch, pull+rebase with upstream, and push to your local
# Usage:
# $ rmain
function rmain() {
  CMD="git checkout main"
  echo $CMD
  $CMD

  CMD="git pull --rebase upstream main"
  echo $CMD
  $CMD

  CMD="git push origin main"
  echo $CMD
  $CMD
}

# Interactive rebase with X commits off head
# Usage:
# $ squash (number from head)
function squashn() {
  if [ -z "$1" ]; then
    NUMBER=2
  else
    NUMBER=$1
  fi

  CMD="git rebase -i HEAD~$NUMBER"
  echo $CMD
  $CMD
}

# Rebase an upstream feature branch
# Usasge:
# $ rfeat (branch: current, or name)
function rfeat() {
  if [ -z "$1" ]; then
    BRANCH=$(git branch --show-current)
  else
    BRANCH=$1
  fi

  CMD="git fetch upstream"
  echo $CMD
  $CMD

  CMD="git checkout $BRANCH"
  echo $CMD
  $CMD

  CMD="git reset --hard upstream/$BRANCH"
  echo $CMD
  $CMD

  CMD="git rebase upstream/main"
  echo $CMD
  $CMD
}

# Pulls and rebases the remote branch
# Usage:
# $ gpull (branch: current, or name)
# $ gpull (remote: origin, or name) (branch: current, or name)
function gpull() {
  if [ -z "$2" ]; then
    BRANCH=$(git branch | grep "*" | awk '{print $2}')
  else
    BRANCH=$2
  fi

  if [ -z "$1" ]; then
    REMOTE='origin'
  else
    REMOTE=$1
  fi

  CMD="git pull --rebase $REMOTE $BRANCH"
  echo $CMD
  $CMD
}

# Pushes a local branch to a remote
# Usage:
# $ gpush (branch: current, or name)
# $ gpush (remote: origin, or name) (branch: current, or name)
function gpush() {
  if [ -z "$2" ]; then
    BRANCH=$(git branch | grep "*" | awk '{print $2}')
  else
    BRANCH=$2
  fi

  if [ -z "$1" ]; then
    REMOTE='origin'
  else
    REMOTE=$1
  fi

  CMD="git push $REMOTE $BRANCH"
  echo $CMD
  $CMD
}

# Force-pushes a local branch to a remote
# Usage:
# $ gpush (branch: current, or name)
# $ gpush (remote: origin, or name) (branch: current, or name)
function gfpush() {
  if [ -z "$2" ]; then
    BRANCH=$(git branch | grep "*" | awk '{print $2}')
  else
    BRANCH=$2
  fi

  if [ -z "$1" ]; then
    REMOTE='origin'
  else
    REMOTE=$1
  fi

  CMD="git push -f $REMOTE $BRANCH"
  echo $CMD
  $CMD
}

# Deletes a branch both locally and from a remote.
# Usage:
# $ branchd (branch: current, or name)
# $ branchd (remote: origin, or name) (branch: current, or name)
function branchd() {
  if [ -z "$1" ]; then
    echo "Missing branch name"
    return 1
  else
    BRANCH=$1
  fi

  if [ -z "$2" ]; then
    REMOTE='origin'
  else
    REMOTE=$2
  fi

  CMD="git branch -d $BRANCH"
  echo $CMD
  $CMD

  CMD="git push $REMOTE :$BRANCH"
  echo $CMD
  $CMD
}

# Deletes a branch both locally and from a remote.
# Usage:
# $ branchd (branch: current, or name)
# $ branchd (remote: origin, or name) (branch: current, or name)
function branchdf() {
  if [ -z "$1" ]; then
    echo "Missing branch name"
    return 1
  else
    BRANCH=$1
  fi

  if [ -z "$2" ]; then
    REMOTE='origin'
  else
    REMOTE=$2
  fi

  CMD="git branch -D $BRANCH"
  echo $CMD
  $CMD

  CMD="git push $REMOTE :$BRANCH"
  echo $CMD
  $CMD
}

# Makes a fixup commit if there are no commits on the branch, otherwise makes a fixup to the first commit on the branch. 
# Usage:
# $ dev
function fixup() {
  git add .
  FIXUP_HASH=$(git log main..HEAD --reverse --format="%H" | head -n 1)
  if [ -z "$FIXUP_HASH" ]; then
    git commit -m "dev(dev): Dev"
  else
    git commit --fixup "$FIXUP_HASH"
  fi
}

# Resets the current branch to upstream/main and cherry-picks the latest commit back on top.
# Useful when old commits no longer match and rebase would conflict.
# Usage:
# $ replant
function replant() {
  BRANCH=$(git branch --show-current)

  if [ "$BRANCH" = "main" ]; then
    echo "Cannot replant on main"
    return 1
  fi

  COMMIT=$(git rev-parse HEAD)
  echo "Saving commit $COMMIT"

  CMD="git fetch upstream"
  echo $CMD
  $CMD

  CMD="git reset --hard upstream/main"
  echo $CMD
  $CMD

  CMD="git cherry-pick $COMMIT"
  echo $CMD
  $CMD
}