#/bin/bash
# test tcp port used or not
#27.06.2023, 20:40
#

IsPortFree()
{
	fuser=$(/usr/sbin/fuser $1/tcp);
	if [[ -z $fuser ]] then
		return 0; #yes, port is free because fuser output is empty
	elif [[ ! -z $fuser ]] then
		return 1; #no, port is busy because fuser output is not empty
	fi
}

echo "---test 3010 :";

IsPortFree 3010 && echo "3010 ist free " || echo "3010 ist busy ";

echo "---test 3011 :"; 

IsPortFree 3011 && echo "3011 ist free " || echo "3011 ist busy ";

