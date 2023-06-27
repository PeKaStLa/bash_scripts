# startAllApps.sh
#################################################################################
#				Peter Stadler					#
#				19.06.2023					#
#										#
#                   this file can be used for cronjob				#
#    check all ports. if a port is unused, it means that the app is down.	#
#              then the app shiuld start automatically				#
#            									#
#################################################################################
# 
# 1. create arrays for name, port and path
# 2. for every app do in loop:
# 2.1 check port
# 2.2. open tmux
# 2.3. send command to tmux terminal
# 2.4. check port again
# 3. send finish email, if at least 1 app was down
#

function EchoShellID()
{
	echo "current Shell: $$";
}

function ExitLastTmuxSession()
{
	tmux kill-session -t $1;
}


EchoShellID;


# 1. create arrays for name, port and path

app_names=("blog" "fewo")
app_ports=(3010 3011)
app_paths=("~/blog" "~/mittendrin")
was_down=("no" "no")

# 2. open for loop

for ((i=0; i<${#app_names[@]}; i++))
do
    # Access array element using the loop index
    echo "Element at index $i: ${app_names[i]}"

echo "Element at index $i: ${app_ports[i]}"

echo "Element at index $i: ${app_paths[i]}"


    fuser_before=$(fuser ${app_ports[i]}/tcp);
    echo $fuser_before;
	
    if [[ -z $fuser_before ]] then
	    echo "${app_ports[i]} ist empty.";
	    echo "Das heißt dass ${app_names[i]} down ist!";
	    was_down[i]="yes";
	    echo "-----exit last tmux session";
	    ExitLastTmuxSession ${app_names[i]};

	    echo "-----check tmux session creation";
	    tmux new-session -d -s ${app_names[i]};
	    if [ $? -eq 0 ]; then 
		    echo "-----tmux new session succeeded"
	    else
		    echo "-----tmux new session failed"
            fi

	    echo "Now start app: ${app_names[i]} again:";
	    # test if i can kill tmux session without killing process.
	    # test failed. node process gets also killed with '&'.
	    #tmux send -t ${app_names[i]} "PORT=${app_ports[i]} /usr/bin/node ${app_paths[i]}/build/index.js &" ENTER;
	    tmux send -t ${app_names[i]} "PORT=${app_ports[i]} /usr/bin/node ${app_paths[i]}/build/index.js" ENTER;
	    #tmux send -t ${app_names[i]} "exit";
    fi

    echo "%%%%%%%%%%%%%%%%%%%%%%%%%%";
done 

echo "nach der großen loop";
EchoShellID;

for i in "${!was_down[@]}"
do
	echo "${app_names[i]} was down: ${was_down[i]}"
	fuser_after=$(fuser ${app_ports[i]}/tcp)
	#sleep 2;
	#echo ""
	#echo $fuser_after;
	#echo ""
	if [[ ! -z $fuser_after ]] then
		echo "${app_names[i]} läuft jetzt.";
	fi

done
