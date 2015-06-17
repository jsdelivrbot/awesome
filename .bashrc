# .bashrc
#stop bell in shell
set bell-style none

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

alias ll="ls -la"

alias eclipseMemory="/home/bgibson/eclipse-new/eclipse/eclipse -Xms512m -Xmx4096m -XX:ReservedCodeCacheSize=1028m"

# diff two config files
kd () { kdiff3 wl/conf/JTGN/$1.xml wl/conf/EBUK/$1.xml ; }
kd2 () { kdiff3 wl/conf/JTGN/$1.xml wl/conf/JTGA/$1.xml ; }
kd3 () { kdiff3 wl/conf/$2/$1.xml wl/conf/$3/$1.xml ; }

kdd() {
  kd3 ahcHotelSearchConfig $1 $2
  kd3 airSearchConfig $1 $2
}

#JDK
JAVA_HOME=/usr/local/java/jdk1.6
export JAVA_HOME

PATH=${PATH}:${JAVA_HOME}/bin:/opt/test-st/bin
export PATH

# helpful hints for commands I forget the syntax of but don't feel like reading the man
alias howtofind="echo \"find . -name '*file*'\""
alias howtogrep="echo \"grep -r searchforme *\" ; echo \"grep -ri --include=*.css searchforme *\" \#\(case insensitive with filetype\)"
alias howtogzip="echo \"gzip -c file1 > foo.gz\""
alias howtoawk="echo  \"awk '<regex> {FS = \\\"<separator>\\\"} {sum+=\\\$<index>} {count+=1} END {print sum/count}' <filesToSearchThrough>\""
alias awkexamples="echo  \"awk '/travel-guide\/United_Kingdom\/London/ {FS = \\\"|\\\"} {sum+=\\\$8} {count+=1} END {print sum/count}' *access*\""
# grep '/travel-guide\/United_Kingdom\/London' *access* | awk -F\| '{sum+=$8} {count+=1} END {print "sum:" sum "\ncount:" count "\naverage:" sum/count}'

alias l="ll"

alias reload="source ~/.bashrc"   #reload the bashrc file in your current terminal session
alias rc="emacs ~/.bashrc"        #open this file
alias emacs="emacs -nw"           #always open imacs in no window view
#alias less="less -S"             #makes less extend lines to the right of the screen instead of cutting them in the middle of the file
mx () { chmod a+x $1 ; }          #make a file executable
alias ns="nslookup"               #alias for nslookup

alias EMACS="emacs"
alias LESS="less"
alias FG="fg"
alias RC="rc"

#grep commands examples for specific directories

grepf () { grep -ri "$1" ./src/main/resources/flows/* ; }
alias gf="grepf"

gjs () { grep -ri --include \*.js --exclude="./src/main/webapp/static/*" "$1" ./src/main/webapp/* ; }

gcss () { grep -ri --include \*.css --include \*.less --exclude="./src/main/webapp/static/*" "$1" ./src/main/webapp/* ; }

#ssh to various common places
dlt () { ssh "devlab$1test.test.net" ; } #ssh to a given devlab*test box
alias 715="dlt 715"                       
alias 691="dlt 691"                       
alias 156="dlt 156"                       
alias 179="dlt 179"                       
alias 180="dlt 180"
alias 184="dlt 184"

rjt () {
    JENKINS_BUILD_NUMBER=$[1 + $(curl -s http://jenkins.test.net/job/test-repo/lastBuild/buildNumber |  xargs)]

    curl -X POST "http://jenkins.test.net/job/test-repo/buildWithParameters?git_branch=$(git rev-parse --abbrev-ref HEAD)&git_repo=https://blah.com/test-repo.git&email=$(git config user.email)" -d token=go

    sleep .2 #sleep for .2 seconds - to convince me it's doing something

    echo "*******************************"
    echo "Jenkins Build #$JENKINS_BUILD_NUMBER Kicked Off"
    echo
    echo "Job:    http://jenkins.test.net/job/test-app/$JENKINS_BUILD_NUMBER/console"
    echo "Repo:   https://stash.test.net/scm/~bgibson/test-app.git"
    echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
    echo "*******************************"
}

#is a current session running
psefgrep () { ps -ef | grep "$1" ; }
w () { 
    if [[ -z "$1" ]] ;then 
	psefgrep app-name
    else
	psefgrep "$1"  
    fi
}

#some script examples
tlas () {
    if [[ -z "$2" ]] ;then
        echo "usage: tlas start test-app 28.63 -d5005"
        echo "usage: tlas stop test-app 28.63"
	echo "usage: tlas status -a"
    else
	/test/tlas/$1.py $2 $3 $4
    fi
}

qb () {
    ./build.sh jar

    if [[ $? -eq 0 ]]; then
        version=`grep version gradle.properties | cut -d '=' -f2`
        cp build/libs/app-tl-"$version".jar src/main/thing/app-tl-"$version".jar
    fi
}

###############GIT STUFF##################

function parse_git_branch () {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

RED="\[\033[0;31m\]"
YELLOW="\[\033[0;33m\]"
GREEN="\[\033[0;32m\]"
BRANCH_COLOR="\[\033[0;36m\]"
NO_COLOR="\[\033[0m\]"

PS1="[\W$BRANCH_COLOR\$(parse_git_branch)$NO_COLOR]\$ "

source ~/.bash-helpers/git-help.sh
source ~/.bash-helpers/git-prompt.sh
source ~/.bash-helpers/git_bash_completion.sh

# GIT ALIASES

# in case you forget to type git
alias add="git add"
alias checkout="git checkout"
alias commit="git commit"
alias difftool="git difftool --no-prompt"
alias dt="difftool"
alias mergetool="git mergetool"
alias mt="mergetool"
alias push="git push"
alias rebase="git rebase"
alias reset="git reset"

# other commands
alias gclean="git clean -f ; git clean -xf *\.REMOTE\.* *\.BASE\.* *\.BACKUP\.* *\.LOCAL\.* *\.orig *~"
alias gconfig="emacs .git/config"
alias gdn="git diff --color=always --name-only origin/master" # show the files that you want to merge
alias gl="git log --oneline --graph --decorate --color=always --pretty=format:'%Cgreen%h%Creset -%C(yellow)%d%Creset %s'| less -R"
alias lg="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)%an <%cn>%Creset' --abbrev-commit --all | less -R"
alias gs="git status"

alias fa="git fetch --all"
alias dom="difftool origin/master"

mr () { git pull origin "refs/pull-requests/$1/from"; }

#GIT NOTES

#git checkout -p #select certain sections of a file to revert (patch versions)

#updating the global config
# git config --global color.ui aut
# git config --global merge.tool kdiff3

# git rebase -i HEAD~2 # squashes the last two commits the last two commits
# git push personal :<BranchName> # deletes a branch on your personal repo
# git push personal :refs/tags/<TagName> # deletes a tag on your personal repo

# git rebase --onto origin/master HEAD^^^ HEAD

# git reflog # a recent history of the commands you ran

# Private Method Unit Test Using Reflection

<<PrivateMethodUnitTestComment

public void testFetchSortedReviews() throws Exception {
        List<String> localeCodes = new ArrayList<String>();
        localeCodes.add("en_US");
        localeCodes.add("fr_FR");
        localeCodes.add("es_ES");
        localeCodes.add("ko_KR");
        localeCodes.add("en_GB");
        localeCodes.add("jp_JP");
        localeCodes.add("zn_CH");
        localeCodes.add("en_AU");
        
        Class<Fetcher> c = Fetcher.class;
        Class[] parTypes = new Class[2];
        parTypes[0] = List.class;
        parTypes[1] = String.class;
        Method m = c.getDeclaredMethod("fetch", parTypes);
        m.setAccessible(true);
        Object[] argTypes = new Object[2];
        argTypes[0] = localeCodes;
        argTypes[1] = "jp";
        Fetcher executor = new Fetcher();
        List<LanguagePreference>langPrefs = (List<LanguagePreference>) m.invoke(executor, argTypes);
        
        assertNotNull(langPrefs);
        assertEquals(7, langPrefs.size());
        assertEquals("jp", langPrefs.get(0).getCode());
        assertEquals("en", langPrefs.get(1).getCode());
        assertEquals("fr", langPrefs.get(2).getCode());
        assertEquals("ko", langPrefs.get(3).getCode());
        assertEquals("es", langPrefs.get(4).getCode());
        assertEquals("zn", langPrefs.get(5).getCode());
        assertEquals(NO_PREF_CODE, langPrefs.get(6).getCode());
}

PrivateMethodUnitTestComment

#look at a file in a jar
alias howtojar="echo 'jar xvf test-test-app.jar META-INF/MANIFEST.MF'; echo 'less META-INF/MANIFEST.MF'"


#SSH and SCP notes
#ssh devbox.test.net mkdir ~/.ssh/ # will make the directory if it doesn't exist already
#scp ~/.ssh/id_dsa.pub devbox.test.net:~/.ssh/authorized_keys
