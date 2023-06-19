
#!/bin/bash
#cron_blog_cicd.sh
#05.06.2023, 11:11
#script for automating CI and CD of the blog-WebApp.
#
#tasks:
#
#1.0 compare latest local and remote git commit hash
#1.1. git pull
#2. npm run build
#3. check ports via fuser XXXX/tcp
#4. declare new port
#5. start detached tmux-server
#6. start new node-server in detached tmux-server
#7. change port in nginx.conf
#8. reload nginx.conf.
#9. kill old node-server-process
#
#files needed:
#/home/ec2-user/blog (git & npm directory)
#~/blog/build/index.js (Build directory muss 'build' heißen)
#/etc/nginx/conf.d/blog_port (diese Datei includen in nginx.conf)
#
#

port1=3020;
port2=3021;

echo "--file start.";

#1.0 compare latest local and remote git commit hash
echo "--get local git commit hash:";
git_local_hash=$(cd /home/ec2-user/blog && /usr/bin/git rev-parse HEAD);
echo "--Git local hash: $git_local_hash";
echo "--Get remote/origin git commit hash:";
git_remote_hash=$(cd /home/ec2-user/blog && /usr/bin/git ls-remote --head | cut -f1);
echo "--Git remote hash: $git_remote_hash";
echo "--compare both";

if [[ $git_local_hash = $git_remote_hash ]] then
        echo "--local and remote hash are the same. No need for update. Exit now";
        exit;
else
        echo "--local and remote hash are not the same.";
        echo "--It means that there is a newer version on github. update now!";
fi

#1.1. git pull works:


echo "--git pull now:";
output1=$(/usr/bin/git -C /home/ec2-user/blog pull);
echo $output1;
echo "--git pull is done.";

echo "--npm run build now:";
# 2. npm run build works:
output2=$(/usr/bin/npm run --prefix /home/ec2-user/blog build);
echo $output2;

echo "--npm run build is done";
# 3. check ports via fuser XXXX/tcp works:
echo "--fuser$port1 check now:";
fuser3020=$(/usr/sbin/fuser $port1/tcp);
echo $fuser3020;
echo "--fuser$port1 check done.";

echo "--fuser$port2 check now:";
fuser3021=$(/usr/sbin/fuser $port2/tcp);
echo $fuser3021;
echo "--fuser$port2 check done."

# 4. declare new port works:
echo "--Now declare port for node-server:"
declare port;
declare killport;

if [[ -z "$fuser3020" ]] then
        port=$port1;
        killport=$port2;
elif [[ -z "$fuser3021" ]] then
        port=$port2;
        killport=$port1;
else
        echo "--Both ports $port1 and $port2 are in use!! Exit now.";
        exit;
fi

echo "--echo port-variable for new node-server:"
echo $port;

echo "--now start new node-server with updated git data";
echo "--for that we create a tmux-server and send the node-command to it";
echo "--create tmux-server named blog$port:";
# 5. start detached tmux-server works:
$(tmux new-session -d -s blog$port);
echo "--send the node-command to tmux-server blog$port:";
# 6. start new node-server in detached tmux-server works:
$(tmux send -t blog$port "PORT=$port /usr/bin/node ~/blog/build/index.js" ENTER);
echo "--node-server should be running on port $port now.";

echo "--check fuser for port $port after sleep 2 seconds:";
sleep 2;


output4=$(/usr/sbin/fuser $port/tcp);
echo $output4;
echo "--all worked until now. The up-to-date node-server is running on $port.";
echo "--now we need to change the nginx.conf, reload nginx and stop the old server on $killport.";

# 7. change port in nginx.conf to new port;
echo "--Change the file nginx/conf.d/blog_port to the new port $port now:";
$(sudo bash -c "echo 'proxy_pass       http://127.0.0.1:$port;' > /etc/nginx/conf.d/blog_port");
echo "--blog_port has the port $port for the new server now."

# 8.  reload nginx.conf.
echo "--relaod nginx.conf with sudo:";
sudo nginx -s reload
echo "--blog.peterstadler.com should show the up-to-date data and server on port $port now.";


# 9.
echo "--kill the old server now on port $killport":
/usr/sbin/fuser -k $killport/tcp
echo "--old server on $killport killed.";

echo "--now maybe check the fuser ports again. Port $killport should be empty. Port $port should be running."

echo "--fuser$port1 check now:";
fuser3020=$(/usr/sbin/fuser $port1/tcp);
echo $fuser3020;
echo "--fuser$port1 check done.";

echo "--fuser$port2 check now:";
fuser3021=$(/usr/sbin/fuser $port2/tcp);
echo $fuser3021;
echo "--fuser$port2 check done."





echo "--whole .sh-file executed successfully.";
