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
#6. EchoEyeCatcher()
#5. CheckIfDollar1Exists()
#4. IsPortFree()
#3. EchoPortFuser()
#2. IsLocalRepoUpToDate()
#1. ExitIfCodeIsNot0()


###############################################################################
###############################################################################
###############################################################################

###############################################################################

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
    git_local_hash=$(cd /home/ec2-user/blog && /usr/bin/git rev-parse HEAD);
    git_remote_hash=$(cd /home/ec2-user/blog && /usr/bin/git ls-remote --head | cut -f1);

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
        echo "Exit code ist 0 :)";
        return 0; #yes, last command worked
    else
        echo "Exit code ist 1 :(";
        exit; 
        #return 1; #no, last command didnt worked
    fi
}

###############################################################################




