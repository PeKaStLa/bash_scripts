#!/bin/bash
#
#################################################################
#                    sendFileSNS.sh                             #
#                     02.07.2023, 10:13                         #
#               last change 02.07.2023, 10:13                   #
#    use amazon sns email to send a file to my own mail 	#
#tasks:              						#
#1. put file content into message-variable                      #
#2. send message in mail via SNS                                #
#################################################################
#
source ~/scripts/functions.sh;

DoesDollarExist "Dollar 1 is missing in sendFileSNS.sh" $1 || exit; 
message=$(< $1);
aws sns publish --topic-arn arn:aws:sns:eu-central-1:617485513502:send_files_for_archiv --message "$message";
echo "Datei wurde in E-Mail gesendet.";


