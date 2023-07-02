#/bin/bash
#
#################################################
#               functions.sh                    #
#  essential functions to use in other scripts  #
#						#
#       This file shall not be executed.        #
#       Only imported into other shell scripts. #
#               29.06.2023 - 18:27              #
#            last change: 02.07.2023            #
#               by Peter Stadler                #
#################################################
#
#Changelog:
#02.07.2023 set 5.1 to DEPRECATED. new version is 5.2. change name to DoesDollarExist()
#	    for better understanding and easier usage.
#
#################################################
#
#
#
#10. SendTextSNS() $1=message-text
#9.  SendFileSNS() $1=filename
#8.  TmuxDeployNode() $1=repo, $2=port
#7.  PullBuildNode() $1=repo
#6.  EchoEyeCatcher() $1=text to be echoed
#5.2 DoesDollarExist() $1=error-message, $2=var to be checked
#5.1 !!! DEPRECATED !!! CheckIfDollarExists() $1=error-message, $2=port or repo to be checked)
#4.  IsPortFree() $1=port
#3.  EchoPortFuser() $1=port
#2.  IsLocalRepoUpToDate() $1=repo-name
#1.  ExitIfCodeIsNot0()

###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################



###############################################################################
#10. SendTextSNS() $1=message-text
###############################

SendTextSNS()
{
        CheckIfDollarExists "Message-text is missing in 'SendTextSNS()'"  $1 || return 1;
        #$1 needs a message-text

        aws sns publish --topic-arn arn:aws:sns:eu-central-1:617485513502:send_files_for_archiv --message "$1";
        echo "Message $1 wurde in E-Mail gesendet.";
}

###############################################################################
#9. SendFileSNS() $1=filename
###############################

SendFileSNS()
{
	CheckIfDollarExists "Filename is missing in 'SendFileSNS()'"  $1 || return 1;
    	#$1 needs a file-name
	
	message=$(< $1);
        aws sns publish --topic-arn arn:aws:sns:eu-central-1:617485513502:send_files_for_archiv --message "$message";
        echo "Datei $1 wurde in E-Mail gesendet.";
}

###############################################################################
#8. TmuxDeployNode() $1=repo, $2=port
######################################

TmuxDeployNode()
{
    CheckIfDollarExists "Repo-name is missing in 'TmuxDeployNode()'"  $1 || return 1;
    #$1 needs a repo-name
    CheckIfDollarExists "Port is missing in 'TmuxDeployNode()'"  $2 || return 1;
    #$2 needs a port
    
    #tmux kill old session
    /usr/bin/tmux kill-session -t $1;
    #tmux new session
    /usr/bin/tmux new-session -ds $1 || return 1;
    #tmux send deploy to session
    tmux send -t $1 "PORT=$2 /usr/bin/node ~/$1/build/index.js" ENTER || return 1;
    #sleep 2 and check for fuser am Port
    sleep 2;
    EchoPortFuser $2 || return 1;
}

###############################################################################
#7. PullBuildNode() $1=repo
##########################

PullBuildNode()
{
    CheckIfDollarExists "Repo-name is missing in 'PullBuildTmuxDeploy()'"  $1 || return 1;
    #$1 needs a repo-name
    
    IsLocalRepoUpToDate $1 && return 1;

    #git pull 
    /usr/bin/git -C /home/ec2-user/$1 pull || return 1;
    #npm run build
    /usr/bin/npm run --prefix /home/ec2-user/$1 build || return 1;
}

###############################################################################
#6. EchoEyeCatcher() $1=text to be echoed
#####################

EchoEyeCatcher()
{
    # echo $1 Parameter in white font on red background
    echo -e '\E[37;41m' "$1"; tput sgr0;
}

###############################################################################
#5.2. DoesDollarExist() $1=error-message, $2=var to be checked
############################

DoesDollarExist()
{
    # takes $1 as error-message
    # and $2 to check it (e.g. Port or Repo or message)
    if [[ ! -z $2 ]] then
        return 0; #yes, $2 exists
    else
        EchoEyeCatcher "$1";
        return 1; #no, $2 doesnt exist
    fi
}

###############################################################################
#DEPRECATED - REPLACE old 5.1 with new 5.2 in all scripts
#5.1. CheckIfDollarExists() $1=error-message, $2=port or repo to be checked
############################

CheckIfDollarExists()
{
    # takes $1 as error-message
    # and $2 for check (e.g. Port or Repo)
    if [[ ! -z $2 ]] then
        return 0; #yes, $2 exists
    else
        EchoEyeCatcher "$1";
        return 1; #no, $2 doesnt exist
    fi
}

###############################################################################
#4. IsPortFree() $1=port
#################

IsPortFree()
{
    CheckIfDollarExists "Port is missing in 'IsPortFree()'" $1 || return 1;
    #$1 needed a port
    fuser=$(/usr/sbin/fuser $1/tcp); #check if port is used by a process
    if [[ -z $fuser ]] then
        return 0; #yes, port is free because fuser output is empty
    elif [[ ! -z $fuser ]] then
        return 1; #no, port is not free because fuser output is not empty
    fi
}

###############################################################################
#3. EchoPortFuser() $1=port
####################

EchoPortFuser()
{
    CheckIfDollarExists "Port is missing in 'EchoPortFuser'" $1 || return 1;
    #$1 needed a port
    fuser=$(/usr/sbin/fuser $1/tcp);
    echo $fuser;
}

###############################################################################
#2. IsLocalRepoUpToDate() $1=repo-name
##############################

IsLocalRepoUpToDate()
{
    CheckIfDollarExists "Repo-name is missing in 'IsLocalRepoUpToDate()'" $1 || return 1;
    #$1 needs a repo/project-name
    git_local_hash=$(/usr/bin/git -C ~/$1 rev-parse HEAD);
    git_remote_hash=$(/usr/bin/git -C ~/$1 ls-remote --head | cut -f1);

    if [[ $git_local_hash = $git_remote_hash ]] then
        return 0; #yes, local and remote the same. local commit is up-to-date
    else
        return 1; #no, local repo is behind.
    fi
}

################################################################################
#1. ExitIfCodeIsNot0()
#########################

ExitIfCodeIsNot0()
{
    if [[ "$?" -eq 0 ]] then
        echo "Exit code is 0, good :)";
        return 0; #yes, last command worked
    else
        echo "Exit code is not 0, bad :(. Exit now.";
        exit;  #because last command didnt worked
    fi
}

###############################################################################



