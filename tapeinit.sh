#!/bin/bash

## PlanEx Tape Init and Preparation Script 	##
## Version 2.0					##
## Modified 04 AUG 2018 			##
## -------------------- 			##

clear

check_mount () {

echo "Check if /dev/nst0 exists..."
echo ""

if [ ! -c /dev/nst0 ] 

then
	echo "Tape drive NOT FOUND!"
	echo "So here is what dmesg says:"
	echo "--------------------------------------"
	local dmesgresult=$(dmesg|grep LSI|grep scsi)
	echo "$dmesgresult"
	echo "--------------------------------------"	
	set -- $dmesgresult
	local hostnum=$(echo $1 |tr -cd 0-9)
	echo "It appears SCSI card is located in Host $hostnum"
	read -p "Do you want to try Force SCSI Host Bus Scan? [Y/n]" yn
	case $yn in
		[Yy]* ) echo "- - -" > /sys/class/scsi_host/host$hostnum/scan;;
		[Nn]* ) exit 1;;
	esac

fi

}

check_drive () {
	
	tape=/dev/nst0
	mt -f $tape status

	if [ $? -eq 0 ]
	then
		echo ""
		echo "Looks like $tape is available. Continuing... "
		echo ""
	else
		echo "Critical: Tape status check FAILED"
		echo "Exiting."
		echo " "
		exit 1
	fi
}

config_drive () {
	
	echo " "
	echo "Setting Drive Parameters:"
	echo "Rewinding"
	mt -f /dev/nst0 rewind
	echo "Setting block size to 256k"
	mt -f /dev/nst0 setblk 256k
	echo "--------------------------"
	echo "Tape Initialisation Complete"
}

## Start Actual Stuff

echo "------------------------------------------"
echo "| Welcome to PlanEx Tape Mounter Script! |"
echo "------------------------------------------"
echo "Reminder: We use nst0 device to NOT rewind!"
echo ""

check_mount
if [ $? -eq 0 ]
then
	check_drive
	if [ $? -eq 0 ]
	then
		config_drive
	fi
fi

