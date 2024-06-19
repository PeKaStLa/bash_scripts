#!/bin/bash
#
#echo start
#date


if [[ $1 = "status" ]] && [[ ! $2 = "stopped" ]] && [[ ! $2 = "running" ]] && [[ ! -z $2 ]];
then	
	echo "Show status of instance: $2 now:"
	aws ec2 describe-instance-status --instance-ids $2  | jq -r '.InstanceStatuses.[].InstanceState.Name '
fi


if [[ $1 = "start" ]] && [[ -z $2 ]]; then
	output_all_stopped_instances=$(aws ec2 describe-instances --filters Name=instance-state-name,Values=stopped | jq -r '.Reservations[].Instances[].InstanceId')
	if [[ ! -z $output_all_stopped_instances ]]; 
	then
		for id in "$output_all_stopped_instances"; 
		do
			ids_to_start+=( $( echo "$id" | tr -d '\r' | cat -v; ) )
		done
		echo "Starting all instances now:"
		aws ec2 start-instances --instance-ids $( echo "${ids_to_start[@]}" ); 
	else
		echo "No stopped instances to start."
	fi
fi


if [[ $1 = "stop" ]] && [[ -z $2 ]]; then
	output_all_running_instances=$(aws ec2 describe-instances --filters Name=instance-state-name,Values=running | jq -r '.Reservations[].Instances[].InstanceId')
	if [[ ! -z $output_all_running_instances ]]; 
	then
		for id in "$output_all_running_instances"; 
		do 
			ids_to_stop+=( $( echo "$id" | tr -d '\r' | cat -v; ) )
		done
		echo "Stopping all instances now:"
		aws ec2 stop-instances --instance-ids $( echo "${ids_to_stop[@]}" ); 
	else
		echo "No running instances to stop."
	fi
fi


if [[ $1 = "status" ]] && [[ -z $2 ]];
then
	echo "Show all instance-statuses now:"
	output_all_statuse=$(aws ec2 describe-instance-status | jq -r '.InstanceStatuses.[] | "\(.InstanceId) is \(.InstanceState.Name)"')
	if [[ ! -z $output_all_statuse ]]; 
	then
		echo "$output_all_statuse"
	else
		echo "No instances are running."
	fi
fi

if [[ $1 = "status" ]] && [[ ! $2 = "stopped" ]] && [[ ! $2 = "running" ]] && [[ ! -z $2 ]];
then	
	echo "Show status of instance: $2 now:"
	aws ec2 describe-instance-status --instance-ids $2  | jq -r '.InstanceStatuses.[].InstanceState.Name '
fi

if [[ $1 = "status" ]] && [[ $2 = "stopped" ]];
then
	echo "Show all stopped instances now:"
	output_all_stopped_instances=$(aws ec2 describe-instances --filters Name=instance-state-name,Values=stopped | jq -r '.Reservations[].Instances[].InstanceId')
	if [[ ! -z $output_all_stopped_instances ]]; 
	then
		echo "$output_all_stopped_instances"
	else
		echo "No instances are stopped."
	fi
fi

if [[ $1 = "status" ]] && [[ $2 = "running" ]];
then 
	echo "Show all running instances now:"
	output_all_running_instances=$(aws ec2 describe-instances --filters Name=instance-state-name,Values=running | jq -r '.Reservations[].Instances[].InstanceId')
	if [[ ! -z $output_all_running_instances ]]; 
	then
		echo "$output_all_running_instances"
	else
		echo "No instances are running."
	fi
fi


# Wildcard * empty Dollar1
if [[ -z $1 ]];
then
	echo -e "Dollar1: $1 is empty. \nUsage: \ncontrol-ec2.sh ['status'|'start'|'stop'] ['stopped'|'running'|<instance-id>]"
	echo -e "Examples: \ncontrol-ec2.sh status \ncontrol-ec2.sh status running \ncontrol-ec2.sh status i-059604ca3cf21bc80"
	echo -e "control-ec2.sh start \ncontrol-ec2.sh stop"
fi


# wait for instances to be stopped: 
# for id in ${ids[@]}; do
#        aws ec2 wait instance-stopped --instance-ids $id;
# done

#echo end
#date
