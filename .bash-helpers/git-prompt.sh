#!/bin/bash

#
# 0: reset
# 1: bold
# 4: underline
# 5: blink
# 7: invert foreground and background

# whatever the foreground color is by default
RESET="\[\e[00m\]"
# Changes not committed 
TEAL="\[\e[00;36m\]"
BOLD_TEAL="\[\e[01;36m\]"
# Suggested merge
YELLOW="\[\e[00;33m\]"
BOLD_YELLOW="\[\e[01;33m\]"
# Untracked files present
BOLD_GREEN="\[\e[01;32m\]"
# Normal dev, no pending changes
GREEN="\[\e[00;32m\]"

#
# Build a specialized prompt to indicate that the
# current location is within a git repo directory.
#
# Put this in the .bashrc
# 'PROMPT_COMMAND=git_prompt_cmd'
# 
# Note that if the repo is large, it may take some
# time to resolve the prompt. Just comment out the
# 'PROMPT_COMMAND=prompt' in the .bashrc file.
#
git_prompt_cmd() {

  #ps_command="\s-\v\$ "
  git_status=`git status 2>&1`

  if [[ "$git_status" =~ "fatal: " ]]; then
    ps_command="[\u:\w]$ "
  else 
    # todo: look at incorporating these...
    #branch_ref=`git symbolic-ref HEAD`    
    #staged=`git diff-index --cached --ignore-submodules --exit-code HEAD`
    #modified=`git diff --ignore-submodules --exit-code HEAD`

    # regex patterns based on `git status`
    branch_regex="^# On branch ([a-zA-Z0-9]*)"
    branch_and_project_head_regex="branch '([a-zA-Z0-9]*)' of .*:.*/(.*)"
    branch_and_project_config="url git@.*/(.*).git"
    changed_not_updated_regex="# Changed but not updated:"
    modified_regex="# Changes not staged for commit:"
    new_file_regex="# Changes to be committed:"
    untracked_regex="# Untracked files:"
    remote_regex="[remote "    

    #fetch_head=`grep -E "$branch_and_project_head_regex" .git/FETCH_HEAD`
    #config_url=`grep -E "$branch_and_project_config" .git/config`
    branch="" 
    project=""

    #if [[ "$fetch_head" =~ $branch_and_project_regex ]]; then
    #   branch="${BASH_REMATCH[1]}"
    #   project="${BASH_REMATCH[2]}"
    if [[ "$git_status" =~ $branch_regex ]]; then
       branch="${BASH_REMATCH[1]}"
       project="" #"\w" #${PWD##*/}
    fi

    add_file=""
    if [[ "$git_status" =~ $untracked_regex ]]; then
      add_file="add,"
    fi
    
    message="$add_file"
    if [[ "$git_status" =~ $changed_not_updated_regex ]]; then
      ps_command="[${BOLD_TEAL}git@$project:$branch(${message}commit)$RESET]$ "
    elif [[ "$git_status" =~ $new_file_regex ]]; then
      ps_command="[${BOLD_TEAL}git@$project:$branch(${message}new)$RESET]$ "
    elif [[ "$git_status" =~ $modified_regex ]]; then
      ps_command="[${BOLD_TEAL}git@$project:$branch(${message}modified)$RESET]$ "
    else
      local_message="($message)"  
      ps_command="[${BOLD_GREEN}git@$project:$branch$local_message$RESET]$ "
      remote=`grep -s "remote " .git/config`

      if [[ "$remote" != "" ]]; then 
        git_diff_upstream=`git diff origin/master`
        if [[ "$git_diff_upstream" != "" ]]; then
          ps_command="[${BOLD_YELLOW}git@$project:$branch(${message}push/merge)$RESET]$ "
        fi
      fi
      
    fi

  fi # end if-else block
  
  export PS1="$ps_command"
}

export -f git_prompt_cmd
