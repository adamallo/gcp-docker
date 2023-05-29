#!/bin/bash
desiredUSER=$1
desiredUID=$2
desiredGID=$3
desiredHOME=$4
KEY=$5

presentUser=$(grep "^$USER:" /etc/passwd | wc -l)
useUser=0

if [[ $presentUser -eq 1 ]]
then
	realUID=$(grep "^$desiredUSER" /etc/passwd | awk -F: '{print $3}')
	realGID=$(grep "^$desiredUSER" /etc/passwd | awk -F: '{print $4}')
	realHOME=$(grep "^$desiredUSER" /etc/passwd | awk -F: '{print $6}')
	realHOME=$(readlink -e $realHOME)
	if [[ $realUID -eq $desiredUID ]] || [[ $realGID -eq $desiredGID ]]
	then

		mkdir -p $desiredHOME
		desiredHOME=$(readlink -e $desiredHOME)
		if [[ $realHOME == $desiredHOME ]]
		then
			useUser=1
		fi
	fi
	if [[ $useUser -eq 0 ]]
	then
		>&2 echo "ERROR: the required user $desiredUSER with UID $realUID, GID $realGID and HOME $realHOME exists but the expected characteristics do not match. Expected UID $desiredUID, GID $desiredGID, HOME $desiredHOME. Globus connect will not be executed and bash will be running under the globus default user"
	fi
else
	#make new user
	>&2 echo "Making new user $desiredUser, UID $desiredUID, GID $desiredGID, HOME $desiredHOME"
	useradd -m -s /bin/bash -N -d $desiredHOME -u $desiredUID -g $desiredGID $desiredUSER
	mkdir -p $desiredHOME
	chown $desiredUser $desiredHOME
	chgrp $desiredGID $desiredHOME
fi

if [[ $useUser -eq 1 ]]
then
	if [[ $USER != $desiredUSER ]]
	then
		su $desiredUser
	fi
	
	/opt/globusconnectpersonal/globusconnectpersonal -start -restrict-paths "rw/$HOME"
	
	if [[ $? -ne 0 ]] && [[ ! -z $key]]
	then	
		/opt/globusconnectpersonal/globusconnectpersonal -setup $key
		/opt/globusconnectpersonal/globusconnectpersonal -start -restrict-paths "rw/$HOME"
	fi
else
	>&2 echo "Failed setup. Container will be waiting for configuration runing bash"
	/bin/bash
fi
