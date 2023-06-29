#!/bin/bash
#
#################################################################
#								#
#                       updateBlog.sh				#
#                     05.06.2023, 11:11				#
#                     last change 29.06.2023			#
#         script for automating CD of the blog-WebApp.  	#
#tasks:								#
#								#
#1. compare latest local and remote git commit hash		#
#2. git pull							#
#3. npm run build						#
#4. kill old tmux process					#
#5. start detached tmux-session					#
#6. start new node-server in detached tmux-session		#
#								#
#files/project/webapp needed:					#
#/home/ec2-user/blog (git & npm directory)			#
#~/blog/build/index.js (Build directory 'build')		#	
#								#
#################################################################

declare -r port=3010;

IsPortFree()
{
        fuser=$(/usr/sbin/fuser $1/tcp);
        if [[ -z $fuser ]] then
                return 0; #yes, port is free because fuser output is empty
        elif [[ ! -z $fuser ]] then
                return 1; #no, port is busy because fuser output is not empty
        fi
}

EchoPortFuser()
{
	echo "--CheckPortFuser() on port $1 now:";
	fuser=$(/usr/sbin/fuser $1/tcp);
	echo $fuser;
	echo "--CheckPortFuser() on port $1 done.";
}

CompareGitLocalRemote()
{
#echo "--get local git commit hash:";
git_local_hash=$(cd /home/ec2-user/blog && /usr/bin/git rev-parse HEAD);
#echo "--Get remote/origin git commit hash:";
git_remote_hash=$(cd /home/ec2-user/blog && /usr/bin/git ls-remote --head | cut -f1);

#echo "--compare both";
if [[ $git_local_hash = $git_remote_hash ]] then
        #echo "--local and remote hash are the same. No need for update. Exit now";
        return 0;
else
        #echo "--local and remote hash are not the same.";
        #echo "--It means that there is a newer version on github. update now!";
	return 1;
fi
}

GitPull() 
{
#echo "--git pull now:";
output1=$(/usr/bin/git -C /home/ec2-user/blog pull);
#echo $output1;
#echo "--git pull is done.";
}

NpmRunBuild()
{
#echo "--npm run build now:";
# 2. npm run build works:
output2=$(/usr/bin/npm run --prefix /home/ec2-user/blog build);
#echo $output2;
#echo "--npm run build is done";
}



# 3. check port via fuser XXXX/tcp works:
echo "--check port and kill app if app runs on port";

local_commit_is_uptodate=CompareGitLocalRemote()
EchoPortFuser $port;

# this works:
#IsPortFree $port && echo "-----All good. Port $port is already empty and unused." || (echo "-----Port $port is used. Kill app now."; fuser -k $port/tcp;);

#check if works without braces
IsPortFree $port && echo "-----All good. Port $port is already empty and unused." || echo "-----Port $port is used. Kill app now."; fuser -k $port/tcp;

echo "--now start new node-server with updated git data";
echo "--for that we create a tmux-server and send the node-command to it";
echo "--create tmux-server named blog$port:";
# 5. start detached tmux-server works:
$(tmux new-session -d -s blog);
echo "--send the node-command to tmux-server blog$port:";
# 6. start new node-server in detached tmux-server works:
$(tmux send -t blog "PORT=$port /usr/bin/node ~/blog/build/index.js" ENTER);
echo "--node-server should be running on port $port now.";

echo "--check fuser for port $port after sleep 2";
sleep 2;
EchoPortFuser $port;


echo "--start .sh file";

#1.0 compare latest local and remote git commit hash
#2. git pull
#3 npm run build

CompareGitLocalRemote && GitPull && NpmRunBuild || exit;

declare -r local_commit_is_up_to_date=CompareGitLocalRemote();

echo "--whole .sh-file executed successfully.";

