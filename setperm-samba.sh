#!/bin/bash
. /etc/init.d/functions

# Batch script to create Samba tags and permissions
# Uses init.d/funtions for success/failure indication

# 1. Check if arguements are passed correctly

if [ $# -eq 0 ]
then
	echo "Usage: $0 username groupname PATH"
	exit 0
elif [ $# -lt 3 ]
then
	echo "ERROR: Missing arguments."
	echo "Usage: $0 username groupname PATH"
	exit 1
elif [ $# -eq 3 ]
then
	echo "Starting script..."
	echo "Username: [$1] Groupname: [$2] Path: [$3]"
	sleep 1
else
	echo "Unexpected Error. Please Retry."
	exit 2
fi

# 2. Check if final vaiable is a directory or not

if [ -d "$3" ]
then
	success
	echo "Checking if PATH is a directory:"
else
	failure
	echo "Checking if PATH is a directory"
	echo "Terminating. Ensure that $3 is a directory."
	exit 1
fi


# Step 1. CHOWN
CHOWN_RSLT=$(chown -R $1 "$3" 2>&1 >/dev/null)
if [ "$?" -eq 0 ]
then
	success
	echo "Changing User Ownership"
else
	failure
	echo $CHOWN_RSLT
fi

CHGRP_RSLT=$(chgrp -R $2 "$3" 2>&1 >/dev/null)
if [ $? -eq 0 ]
then
	success
	echo "Changing Group Ownership"
else
	failure
	echo $CHGRP_RSLT
fi

CHCON_RSLT=$(chcon -R -t samba_share_t "$3" 2>&1 >/dev/null)
if [ $? -eq 0 ]
then
	success
	echo "Setting Samba Filesystem Tag"
else
	failure
	echo $CHCON_RSLT
fi

CHMOD_RSLT=$(chmod -R 775 "$3" 2>&1 >/dev/null)
if [ $? -eq 0 ]
then
	success
	echo "Setting permission to 775"
else
	failure
	echo $CHMOD_RSLT
fi

echo "-------------------------"
echo "Setup Completed"
