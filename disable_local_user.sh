#!/bin/bash

# Make sure the script is being executed with superuser privileges.
if [[ "${UID}" -ne 0 ]]
then
	echo "No ets superusuari, no pots executar l'escript." >&2
	exit 1
fi

# Display the usage and exit.
usage() {
	echo "Us de $0 [-dar] USUARI" >&2
	echo '-d Deletes accounts instead of disabling them' >&2
	echo '-r Removes the home directory associated with the account(s)' >&2
	echo '-a Creates an archive of the home directory associated with the accounts(s) and stores the archive in the /archives directory' >&2
	exit 2
}

dishable() {
	# Check to see if the chage command succeeded.
	# We don't want to tell the user that an account was disabled when it hasn't been.
	usermod -L $1
	if [ $? -ne 0 ]
	then
		echo "L'usuari $1 no s'ha pogut deshabilitar." >&2
	else
		echo "L'usuari $1 ha estat deshabilitat."
	fi
	exit 3
}

delete() {
	# Delete the user.
	userdel $1
	
	# Check to see if the userdel command succeeded.
	# We don't want to tell the user that an account was deleted when it hasn't been.
	if [ "$?" -ne 0 ]
	then
		echo "L'usuari $1 no s'ha pogut eliminat." >&2
	else
		echo "L'usuari $1 ha estat eliminat."
	fi
	exit 5
}

archive() {
	# Create an archive if requested to do so.
	DIRECTORY=/archives
	
	# Make sure the ARCHIVE_DIR directory exists.
	if [ ! -d "$DIRECTORY" ]
	then
		echo "No existeix el directori d'arxius."
		echo "Creant directori d'arxius a /archives..."
		mkdir $DIRECTORY
		if [ "$?" -eq 0 ]
		then
			echo "Directori d'arxius creat."
		else
			echo "No s'ha pogut crear el directori d'arxius" >&2
			exit 4
		fi
	fi
	
	# Archive the user's home directory and move it into the ARCHIVE_DIR
	ARCHIVE=$1.tar.gz
	tar -czvf $ARCHIVE /home/$1 2>&1 > /dev/null
	mv $ARCHIVE $DIRECTORY/$ARCHIVE
}


remove_home() {
	rm -r /home/$1
	if [ "$?" -eq 0 ]
	then
		echo "Directori home de $1 eliminat."
	else
		echo "No s'ha pogut eliminar el directori home de $1" >&2
	fi
}

# If the user doesn't supply at least one argument, give them help.
if [ -z $1 ]
then
	usage
fi

if [ $# -eq 1 ]
then
	ID_USUARI=`id -u $1`
	if [ $ID_USUARI -gt 999 ]
	then
		dishable $1
	fi
fi

# Parse the options.
# Loop through all the usernames supplied as arguments.
# Make sure the UID of the account is at least 1000.
while getopts :d:r:a: OPTION
do
  case $OPTION in
    d)
		ID_USUARI=`id -u $OPTARG`
		if [ "$ID_USUARI" -lt 1000 ]
		then
			echo "Usuari $OPTARG amb UID inferior a 1000." >&2
		else
			delete $OPTARG
		fi
	;;
	a)
		ID_USUARI=`id -u $OPTARG`
		if [ "$ID_USUARI" -lt 1000 ]
		then
			echo "Usuari $OPTARG amb UID inferior a 1000." >&2
		else
			archive $OPTARG
		fi
	;;
    r)
		ID_USUARI=`id -u $OPTARG`
		if [ "$ID_USUARI" -lt 1000 ]
		then
			echo "Usuari $OPTARG amb UID inferior a 1000." >&2
		else
			remove_home $OPTARG
		fi
	;;
    ?)
		usage
	;;
  esac
done
# Remove the options while leaving the remaining arguments.
shift #$(($OPTIND - 1))


dishable $1
