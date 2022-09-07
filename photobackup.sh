#!/bin/bash

# Photo and Production Media Sync

# Check Dest Directory first

sourceroot=/data/3ware/
photoroot=/data/tapebackup/
productionroot=/data/extras/

#echo "----------------------------"
echo "Secondary Backup for Media  "
#echo "----------------------------"
echo " "
echo "Backup Started on $(date)"

if [ -d $sourceroot ]
then
	echo " "
	echo "Source Drive Mount Check: [$sourceroot]"
	if [ -d $photoroot ]
	then
		echo "Backup Drive Mount Check: [$photoroot]"
		echo " "
	else	
		echo " "
		echo "Critical: Backup destination [$photoroot] is NOT available"
		echo "Backup Task NOT STARTED"
		echo " "
		exit 1
	fi
else
	echo " "
	echo "Critical: Source drive [$sourceroot] appears NOT available"
	echo "Backup Task NOT STARTED"
	echo " "
	exit 1
fi

echo "Starting sync for PhotoMaster..."
echo "--------------rSync Log-----------------"
rsync -avh --delete $sourceroot/PhotoMaster/ $photoroot/PhotoMaster/

if [ $? -eq 0 ]
then
	echo " "
	echo "PhotoMaster Backup Completed"
else
	echo " "
	echo "PhotoMaster Backup FAILED"
fi
echo "--------------rSync Log-----------------"
echo " "
echo "Starting sync for Production..."
echo "--------------rSync Log-----------------"
rsync -avh --delete $sourceroot/Production/ $productionroot/Production/

if [ $? -eq 0 ]
then
	echo " "
	echo "Production Backup Completed"
else
	echo " "
	echo "Production Backup FAILED"
fi
echo "--------------rSync Log-----------------"

echo " "
echo "Backup Finished on $(date)"
echo "Backup Task All Complete"
