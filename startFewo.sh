#!/bin/bash
# script to start mittendrin-application if it stopped some time before

echo "--file start."
echo "--Cronjob checkt jetzt den Status. ";

fuser_vorher=$(/usr/sbin/fuser 3030/tcp);
echo "--Fuser-vorher: $fuser_vorher"

if [[ -z "$fuser_vorher" ]] then
        echo "--Fuser-3030/tcp-Prozess-ID ist empty. Fewo-Website also down. Node-App wird jetzt neu gestartet!!";
        echo "--For that we create a tmux-server and send the node-command to it. Create tmux-server named fewo:";
        tmux new-session -d -s fewo;
        echo "--send the node-command to tmux-server fewo:"
        tmux send -t fewo "PORT=3030 /usr/bin/node ~/mittendrin/build/index.js" ENTER;
        echo "--node-server should be running on port 3030 now. check fuser for port 3030 after sleep 2 seconds:";
        sleep 2;
        fuser_nachher=$(/usr/sbin/fuser 3030/tcp);
        echo "--Fuser-nachher: $fuser_nachher";
        echo "--Now send SNS-mail:";
        message="Fewo/Mittendrin war down und wurde durch diesen cronjob (fewo_restart.sh) neu gestartet. fuser als fewo down war: $fuser_vorher .............. fuser nach dem Neustart: $fuser_nachher ..............";
        /usr/bin/aws sns publish --topic-arn arn:aws:sns:eu-central-1:617485513502:mittendrin_status --message "$message";
else
        echo "--Fewo ist gar nicht down.";
fi

echo "--file execution finished.";
