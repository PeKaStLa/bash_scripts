#/bin/bash
#
#################################################
#               functions.sh                    #
#       This file shall not be executed.        #
#       Only imported into other shell scripts. #
#               29.06.2023 - 18:27              #
#               by Peter Stadler                #
#################################################
#
#8. NpmRunBuild()
#7. GitPull()
#6. EchoEyeCatcher()
#5. CheckIfDollar1Exists()
#4. IsPortFree()
#3. EchoPortFuser()
#2. IsLocalRepoUpToDate()
#1. ExitIfCodeIsNot0()


###############################################################################
###############################################################################
###############################################################################
#8. NpmRunBuild()
##################

NpmRunBuild()
{
    CheckIfDollar1Exists $1 || return 1; #$1 needs a repo/project-name
    /usr/bin/npm run --prefix /home/ec2-user/$1 build;
}

###############################################################################
#7. GitPull()
##############

GitPull()
{
    CheckIfDollar1Exists $1 || return 1; #$1 needs a repo/project-name
    /usr/bin/git -C /home/ec2-user/$1 pull;
}

###############################################################################
#6. EchoEyeCatcher()
#####################

EchoEyeCatcher()
{
    # echo $1 Parameter in white font on red background
    echo -e '\E[37;41m' "$1"; tput sgr0;
}

###############################################################################
#5. CheckIfDollar1Exists()
###########################

CheckIfDollar1Exists()
{
    if [[ ! -z $1 ]] then
        return 0; #yes, $1 exists
    else
        EchoEyeCatcher "ERROR - Dollar 1 doesnt exist! $1";
        return 1; #no, $1 doesnt exist
    fi
}

###############################################################################
#4. IsPortFree()
#################

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

###############################################################################
#3. EchoPortFuser()
####################

EchoPortFuser()
{
    CheckIfDollar1Exists $1 || return 1; #$1 needed a port
    fuser=$(/usr/sbin/fuser $1/tcp);
    echo $fuser;
}

###############################################################################
#2. IsLocalRepoUpToDate()
##############################

IsLocalRepoUpToDate()
{
    CheckIfDollar1Exists $1 || return 1; #$1 needs a repo/project-name
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
        echo "Exit code is not 0, bad :(";
        exit;  #because last command didnt worked
    fi
}

###############################################################################
#####



