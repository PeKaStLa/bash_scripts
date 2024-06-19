#!/bin/bash
#
#################################################################
#                       updateBlog.sh                           #
#                     by Peter Stadler                          #
#                     05.06.2023, 11:11                         #
#                     last change 29.06.2023                    #
#         script for automating CD of the blog-WebApp.          #
#tasks:                                                         #
#                                                               #
#1. compare latest local and remote git commit hash             #
#2. git pull                                                    #
#3. npm run build                                               #
#4. kill old tmux process                                       #
#5. start detached tmux-session                                 #
#6. start new node-server in detached tmux-session              #
#                                                               #
#files/project/webapp needed:                                   #
#/home/ec2-user/blog (git & npm directory)                      #
#~/blog/build/index.js (Build directory 'build')                #
#                                                               #
#################################################################

declare -r port=3010;


EchoEyeCatcher()
{
    # echo $1 Parameter in white font on red background
    echo -e '\E[37;41m' "$1"; tput sgr0;
}

#check
CheckIfDollar1Exists()
{
    if [[ ! -z $1 ]] then
        return 0; #yes, $1 exists
    else
        EchoEyeCatcher "ERROR - Dollar 1 doesnt exist! $1";
        return 1; #no, $1 doesnt exist
    fi
}

CheckIfDollar2Exists()
{
    if [[ ! -z $2 ]] then
        return 0; #yes, $2 exists
    else
        EchoEyeCatcher "ERROR - Dollar 2 doesnt exist! $1";
        return 1; #no, $2 doesnt exist
    fi
}


#check
IsPortFree()
{
    CheckIfDollar1Exists $1 || return 1; #$1 needed a port
    fuser=$(/usr/sbin/fuser $1/tcp); #check if port is used by a process
    if [[ -z $fuser ]] then
        return 0; #yes, port is free because fuser output is empty
    elif [[ ! -z $fuser ]] then
        return 1; #no, port is not free because fuser output is not empty
    fi
}

#check
EchoPortFuser()
{
    CheckIfDollar1Exists $1 || return 1; #$1 needed a port
    fuser=$(/usr/sbin/fuser $1/tcp);
    echo $fuser;
}


#check
IsLocalRepoUpToDate()
{
    CheckIfDollar1Exists $1 || return 1; #$1 needs a repo/project-name
    git_local_hash=$(cd /home/ec2-user/$1 && /usr/bin/git rev-parse HEAD);
    git_remote_hash=$(cd /home/ec2-user/$1 && /usr/bin/git ls-remote --head | cut -f1);
    
    if [[ $git_local_hash = $git_remote_hash ]] then
        return 0; #yes, local and remote the same. local commit is up-to-date
    else
        return 1; #no, local repo is behind.
    fi
}


IsLocalRepoUpToDate()
{
    CheckIfDollar1Exists $1 || return 1; #$1 needs a repo/project-name
    git_local_hash=$(cd /home/ec2-user/$1 && /usr/bin/git rev-parse HEAD);
    git_remote_hash=$(cd /home/ec2-user/$1 && /usr/bin/git ls-remote --head | cut -f1);
    
    if [[ $git_local_hash = $git_remote_hash ]] then
        return 0; #yes, local and remote the same. local commit is up-to-date
    else
        return 1; #no, local repo is behind.
    fi
}

#check
ExitIfCodeIsNot0()
{
    if [[ "$?" -eq 0 ]] then
        echo "Exit code ist 0 :)";
        return 0; #yes, last command worked
    else
        echo "Exit code ist 1 :(";
        echo "exit now"; #replace with exit;
        #return 1; #no, last command didnt worked
    fi
}




PullBuildTmuxDeploy()
{
    CheckIfDollarExists "Repo-name is missing in 'PullBuildTmuxDeploy()'"  $1 || return 1;
    #$1 needs a repo-name
    
    CheckIfDollarExists "Port is missing in 'PullBuildTmuxDeploy()'"  $2 || return 1;
    #$2 needs a port

    IsLocalRepoUpToDate $1 && return 1;

    #git pull 
    /usr/bin/git -C /home/ec2-user/$1 pull || return 1;
    #npm run build
    /usr/bin/npm run --prefix /home/ec2-user/$1 build || return 1;
    #tmux kills old session
    /usr/bin/tmux kill-session -t $1;
    #tmux new session
    /usr/bin/tmux new-session -ds $1 || return 1;
    #tmux send deploy to session
    tmux send -t $1 "PORT=$2 /usr/bin/node ~/$1/build/index.js" ENTER || return 1;
    #sleep 2 and check for fuser am Port
    sleep 2;
    EchoPortFuser $2 || return 1;
}



PullBuildTmuxDeployNode()
{
    CheckIfDollarExists "Repo-name is missing in 'PullBuildTmuxDeployNode()'"  $1 || return 1;
    #$1 needs a repo-name
    IsLocalRepoUpToDate $1 && return 1;

    #git pull 
    /usr/bin/git -C /home/ec2-user/$1 pull || return 1;
    #npm run build
    /usr/bin/npm run --prefix /home/ec2-user/$1 build || return 1;

}


TmuxDeployNode()
{
    CheckIfDollarExists "Repo-name is missing in 'TmuxDeployNode()'"  $1 || return 1;
    #$1 needs a repo-name
    CheckIfDollarExists "Port is missing in 'TmuxDeployNode()'"  $2 || return 1;
    #$2 needs a port

    /usr/bin/tmux kill-session -t $1;
    #tmux new session
    /usr/bin/tmux new-session -ds $1 || return 1;
    #tmux send deploy to session
    tmux send -t $1 "PORT=$2 /usr/bin/node ~/$1/build/index.js" ENTER || return 1;
    #sleep 2 and check for fuser am Port
    sleep 2;
    EchoPortFuser $2 || return 1;
}

GitPull()
{
    CheckIfDollar1Exists $1 || return 1; #$1 needs a repo/project-name
    /usr/bin/git -C /home/ec2-user/$1 pull;
}


NpmRunBuild()
{
    CheckIfDollar1Exists $1 || return 1; #$1 needs a repo/project-name
    /usr/bin/npm run --prefix /home/ec2-user/$1 build;
}


TmuxKillSession()
{
    CheckIfDollar1Exists $1 || return 1; #$1 needs a repo/project-name
    /usr/bin/tmux kill-session -t $1;
}


TmuxNewSession()
{
    CheckIfDollar1Exists $1 || return 1; #$1 needs a repo/project-name
    /usr/bin/tmux new-session -ds $1
}


SendToSession()
{
    CheckIfDollar1Exists $1 || return 1; #$1 needs a repo/project-name
    CheckIfDollar2Exists $2 || return 1; #$2 needs a command

    /usr/bin/tmux send -t $1 "$2" ENTER;
}








CompareGitLocalRemote && GitPull && NpmRunBuild || exit;

declare -r local_commit_is_up_to_date=CompareGitLocalRemote();



