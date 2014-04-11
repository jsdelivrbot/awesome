#~/bin/bash

export VERBOSE="false"
export SIMULATE="false"

#
# print out commands to console
git_toggle_verbose() {
  
  if [[ "$VERBOSE" == "true" ]] ; then
    echo "setting verbose to false"
    VERBOSE="false"
  else
    echo "setting verbose to true"
    VERBOSE="true"
  fi    
}

#
# simulate will skip command execution
git_toggle_simulate() {
    
  if [[ "$SIMULATE" == "true" ]] ; then
    echo "setting simulate to false"
    SIMULATE="false"    
  else
    echo "setting 'simulate to true"
    SIMULATE="true"
  fi
}

# dump commands
verbose() {
  if [[ $VERBOSE == "true" ]] ; then
    echo -e "$@"
  fi
}

#
# dump command or execute command
simulate() {
  command=`echo -e "$@"`

  if [[ "$SIMULATE" == false ]] ; then
    $command
  else
    #echo "Simulated: $command"
    dry_run="$command --dry-run"
    $dry_run
  fi
}

git_help_dev() {
  echo "**************************************************************************"
  echo "Typical developer workflow:"
  echo "0) Ensure you have a personal remote repo to work in"
  echo "1) Work on a feature/bug"
  echo "2) Unit/service tests"
  echo "3) Code/design review"
  echo "4) Acceptance testing (if applicable)"
  echo "5) Update ChangeLog"
  echo "6) Promote changes to 'master'"
  echo ""
  echo "git_toggle_verbose:               print all git commands"
  echo "git_toggle_simulate:              do not execute git commands" 
  echo ""
  echo ""
  echo "Working on a feature (local git repo):"
  echo "git_clone/git_checkout            retrieve the code"
  echo "git_update                        fetch all streams locally"
  echo "git_checkout(jira id)             checkout code with jira-id branch"
  echo "git_add_commit(file)              add any new file(s)"
  echo "git_fetch_and_rebase              fetch, rebase, merge with master"
  echo "git"
  echo ""
  echo ""
  echo "All commands:"
  echo "git_diff_personal_and_origin():     differences between personal repo clone and basis"
  echo "git_add_target(remote repo):        add a remote target"
  echo "git_update():                       fetch all in a git repo (cwd unaffected)"
  echo "git_update_pull(remote branch):     pull (fetch + merge) from a remote branch"
  echo "git_revert_to_master():             reverts all local changes to master"
  echo "git_cherry_pick_lost_local()        recover any local changes from a revert"
  echo "git_branch(branch):                 create a new branch"
  echo "git_add_commit(file message)        add, commit a file with comment"
  echo "git_fetch_and_rebase():             fetch, rebase, merge with master"
  echo "git_manual_merge(message):          a manual merge due to rebase issues"
  echo ""
  echo "****************************************************************************"
}


git_help_commit() {
  echo "**************************************************************************"
  echo "Branch Structure: "
  echo "Master(ci):                       frequent commits from developers"
  echo "RC:                               FQA builds, low frequency, Committers only"
  echo "Release:                          Production builds, Committers only"
  echo ""
  echo "Workflow Rules:"
  echo "1) Push commits to 'Master(ci)' often"
  echo "2) Rebase high activity branches onto low activity branches (ex: master to rc)"
  echo "3) Never rebase lower activity branches onto higher activity branches"
  echo "4) Push/rebase changes from 'master' to RC on a regular basis"
  echo "5) Cherry pick from low activity depots to high activity depots (ex: release to rc)"
  echo "6) minimize cherry picks"
  echo ""
  echo "git_toggle_verbose:               print all git commands"
  echo "git_toggle_simulate:              do not execute git commands" 
  echo ""
  echo ""
  echo "git_add_target(remote repo):              add a remote target"
  echo "git_update():                             fetch all in a git repo"
  echo "git_update_with_remote(remote branch):    pull from a remote branch (origin master)"
  echo "git_revert_to_master():                   reverts all local changes to master"
  echo "git_cherry_pick_lost_local()              recover any local changes from a revert"
  echo "git_branch(branch):                       create a new branch"
  echo "git_add_commit(file message)              add, commit a file with comment"
  echo "git_fetch_and_rebase():                   fetch, rebase, merge with master"
  echo "git_manual_merge(message):                a manual merge due to rebase issues"
  echo ""
  echo "***********************************************************************************"
}

#################################################################################
###################### branching ###############################################

#
# Display all existing branches
git_branch_display_all() {
  command="git branch -a"
  verbose "$command"
  simulate "$command"
}

#
# Delete a specific branch
git_branch_delete() {
  branch="$1"
  command="git branch -D $branch"
  verbose "$command"
  simulate "$command"
}

#
# Create a new branch in the repo
# $1: the branch stream to checkout to
#
git_branch_switch() {
  command="git checkout -b $1"
  verbose "$command"
  simulate $command
}

###############################################################
################## diffs ######################################

#
# Check the difference between a personal clone and basis master branch
git_diff_personal_and_origin() {
  command="git diff personal/master origin/master"
  verbose "$command"
  simulate "$command"
}

#
# Setup a personal remote for a repo. Note that you must
# already have access to that project to add repos.
# $1: project
# $2: repo-name
git_setup_personal() {
  command="git remote add personal git@git.orbitz.net:~$USER/$1/$2.git"
  simulate $command
}

#
# clone a repo with the public, read-only
# $1: project
# $2: repository
git_clone_http() {
  command="git clone git://git.orbitz.net/$1/$2.git"
  verbose $command
  simulate $command
}

#
# relies on ssh key to allow/clone a repo
# $1: project
# $2: repository
git_clone_ssh() {
  command="git clone git@git.orbitz.net:$1/$2.git"
  verbose $command
}

#
# $1: the name of your remote target
# $2: the remote repo url
git_add_target() {
  command="git remote add $1 git@git.orbitz.net:$2"
  verbose $command
  simulate $command
}

# Be in a git repo
git_update() {
  command="git fetch --all"
  verbose $command
  simulate $command
}

#
# $1: Which remote origin to pull from
# $2: which branch on that origin to pull from
git_update_with_remote() {
  command="git pull $1 $2"
  verbose $command
  simulate $command
}

# 
# Be in a git repo and revert any/all local changes
# to the 'master' branch. You may recover those changes
# with 'git_cherry_pick_lost_locals()'
git_revert_to_master() {
  command1="git status"
  command2="git checkout master"
  command3="git reset --hard origin/master"

  verbose "$command1\n$command2\n$command3"
  simulate $command1
  simulate $command2
  simulate $command3
}

#
# If you lost changes by accident by reverting
# to changes from 'master' or some other backing
# branch, then try this. Pick the 'sha' that has
# the commit you desire.
git_cherry_pick_lost_local() {
  command1="git reflog"
  # wait for response from screen
  read sha
  command2="git cherry-pick $sha"
  verbose "$command2"
}



#
# $1: the file to add (pending change)
# $2: the commit message (jira-id, etc)
# 
git_add_commit() {
  command1="git add $1"
  command2="git commit -m $2"
  command2="git commit -m \"$2\""

  # todo: verify jira-id pattern exists in comment

  verbose "$command1\n$command2"
  simulate $command1
  simulate $command2
}

#
# Add an untracked or new file
# $1: The file or file pattern to add
git_add() {
  command="git add $1"
  verbose "$command"
  simulate $command
}

#
# Commit changes to a file or files
# $1: the file or file-pattern to commit
# $2: the message for the commit (required)
git_commit() {
  command="git commit $1 -m $2"
  command="git commit $1 -m \"$2\""
  verbose "$command"
  simulate $command
}

#
# checkout jira-id branch
# fetch origin
# rebase onto origin/master
# 'interaction/read from screen'
# push to 'personal' remote
#
# $1: jira-id
# $2: 'personal' 
# 
git_review() {
  command1="git checkout $1"
  command2="git fetch -f origin"
  command3="git rebase -i origin/master"
  command4="git push -f personal $1"

  verbose "$command1\n$command2\n$command3\nConsole Interaction\n$command4"
  simulate $command1
  simulate $command2
  simulate $command3

  read rebase_foo
  simulate $command4
}

#
# Update code under review and ammend the log
# $1: jira-id
# $2: merge request id
git_update_per_review() {
  command1="git commit --amend -a"
  command2="git push origin $1:refs/merge-requests/$2"

  verbose "$command1\n$command2"
  simulate $command1
  simulate $command2
}

#
# update your current branch and promote
# to 'master' after review is complete.
# $1: jira-id
# $2: merge-id
git_promote_after_review() {
  command1="get fetch origin"
  command2="git rebase origin/master"
  command3="git push origin $1:refs/merge-requests/$2"


}

#
# fetch, rebase, merge with "master"
# 
# For merge conflicts, see 'git_manual_merge()'
#
git_master_fetch_and_rebase() {
  command1="git fetch -f origin"
  command2="git rebase origin/master"

  verbose "$command1\n$command2"
  simulate $command1
    # todo: handle merge failure 
    #       "Merge conflict"
    #       "Failed to merge"
    #       "Patch failed at"
  simulate $command2
}

#
# 
git_manual_merge() {
  command1="git commit -am $1"
  command2="git rebase --continue"
  verbose "$command1\n$command2"

  simulate $command1
  simulate $command2
}

#
# Review changes and merge:
# $1: merge-id
#
# Warning: pull = "fetch + merge" and will potentially
#                 overwrite changes unintentionally.
git_review_and_merge() {

  merge-id="$1"
  command1="git fetch origin"
  command2="git checkout -b $merge-id origin/master"
  command3="git reset --hard origin/master"
  command4="git pull origin refs/merge-requests/$merge-id"
  command5="git log --pretty=oneline --abbrev-commit origin/master..HEAD"

  verbose "$command1\n$command2\n$command3\n$command4\n$command5"
  simulate "$command1"
  simulate "$command2"
  simulate "$command3"
  simulate "$command4"
  simulate "$command5"

  ## recursive merge?
  #command6="git rebase origin/master"
  #command7="git log --pretty=oneline --abbrev-commit origin/master..HEAD"
  #command8="git diff origin/master" 
}

git_committer_merge() {

  merge-review="$1"
  command1="git fetch origin"
  command2="git checkout master"
  command3="git reset --hard origin/master"
  command4="git merge --ff-only $merge-review"
  command5="git commit --amend -s"
  command6="git push origin master"
}

#
# Should be in the git repo locally
git_committer_merge_simple() {
  
  verbose "part1: pulling, and squashing commit message"  
  mr_request_id="$1"
  command1="git fetch origin"
  # Create new branch for review
  command2="git checkout -b review-mr-$mr_request_id origin/master"
  # Clear out all other changes
  command3="git reset --hard origin/master"
  # Perform fetch + merge for the merge-request branch (on gitorious)
  command4="git pull origin refs/merge-requests/$mr_request_id"
  # Squash the commits to master (where HEAD is pointing)?
  command5="git log --pretty=oneline --abbrev-commit origin/master..HEAD"

  verbose "$command1\n$command2\n$command3\n$command4\n$command5"
  simulate "$command1"
  simulate "$command2"
  simulate "$command3"
  simulate "$command4"
  simulate "$command5"

  verbose "merging and pushing merge request to master"

  # Fetch 'origin' for current branch (should be master)
  command6="git fetch origin"
  # Swith to master branch
  command7="git checkout master"
  # Ensure no extraneous changes in 'master'
  command8="git reset --hard origin/master"
  # Merge the branch (if review is ok) with current branch (master)
  command9="git merge --ff-only review-mr-$mr_request_id"
  # Sign the original commit message with current user
  command10="git commit --amend -s"
  # Push changes to master branch on gitorious
  #command11="git push origin master"

  

  verbose "$command6\n$command7\n$command8\n$command9\n$command10\n$command11"
  simulate "$command6"
  simulate "$command7"
  simulate "$command8"
  simulate "$command9"
  simulate "$command10"
  simulate "$command11"
}

