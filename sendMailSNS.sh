#!/bin/bash
#use amazon sns email to send files for my own archiv
#...

aws sns publish --topic-arn arn:aws:sns:eu-central-1:617485513502:send_files_for_archiv --message "$1";
echo "Parameter $1 wurde in E-Mail gesendet.";




