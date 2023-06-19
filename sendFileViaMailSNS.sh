#!/bin/bash
#use amazon sns email to send files for my own archiv
#...

#message=$(< ~/scripts/text_mail.sh);

#message=$(< ~/scripts/cron_blog_cicd.sh);

#message=$(< /etc/nginx/nginx.conf);

#message=$(< blog_deploy_latest.sh);

if [[ -z $1 ]] then
        echo " Variable Dollar 1 ist empty. Bitte gib eine zu sendende Datei als 1. Argument an.";
        exit;
else
        message=$(< $1);
        aws sns publish --topic-arn arn:aws:sns:eu-central-1:617485513502:send_files_for_archiv --message "$message";
        echo "Datei wurde in E-Mail gesendet.";
fi
