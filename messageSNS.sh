#!/bin/bash
#
#################################################################
#                    messageSNS.sh                              #
#                     02.07.2023, 10:43                         #
#               last change 02.07.2023, 10:43                   #
#    use amazon sns email to send a message to my own mail      #
#tasks:                                                         #
#1. send message in mail via SNS                                #
#################################################################
#
source functions.sh;

DoesDollarExist "Dollar 1 is missing in messageSNS.sh" $1 || exit;

aws sns publish --topic-arn arn:aws:sns:eu-central-1:617485513502:send_files_for_archiv --message "$1";
echo "Parameter $1 wurde in E-Mail gesendet.";




