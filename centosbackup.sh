#!/bin/bash

# CentOS 6 System Backup Script for JOYFUL
# Set environment

backuptime=$(date +%d%b%Y-%Hh%M)
backupdir=/data/extras/CentosBackup/
sysinfo=/root/sysinfo.txt

# Define custom functions

echostamp()
{
	echo $(date "+%b %d %H:%M:%S ") $1
}

successmsg()
{
	echo " "
	echo " "
	echo "----------------------------"
	echo "   System Backup SUCCESS    "
	echo "----------------------------"
}

failmsg()
{
	echo " "
	echo " "
	echo "----------------------------"
	echo "   System Backup FAIL       "
	echo "----------------------------"
}

###############################
# Start Main Backup Procedure #
###############################

#echo "----------------------------"
echo "   System Backup STARTING   "
#echo "----------------------------"
echo " "
echo " "
echostamp "Checking if $backupdir is ready..."

if [ -d $backupdir ]
then 
	echostamp "$backupdir is available for use. Proceeding."
else
	echostamp "Critical: Backup destination not available. Terminating"
	failmsg
	exit 1
fi

echostamp "Creating System Info under $sysinfo"

#
# Create a basic sysinfo on root directory
#

cat << EOT > $sysinfo

System Information Reference
As of $backuptime
===========================
Hostname: $(uname -n)
CPU: $(cat /proc/cpuinfo |grep name | sed -n '1p' | awk '{print substr($0,14)}')
RAM: $(awk '/MemTotal/ {print $2}' /proc/meminfo) KB
OS: $(cat /etc/redhat-release)
Kernel: $(uname -r)
===========================

Disk Structure
--------------
$(lsblk)

XFS/NFS Mount Options
--------------
$(mount |grep "type xfs")
$(mount |grep "type nfs")

YUM Installed Packages
--------------
$(yum list installed)

EOT

#
# Sysinfo finished. Moving onto actual backup....
# 

echostamp "Starting rSync..."
echo " "
rsync -avhxx --exclude={"/etc/fstab","/tmp","/var/tmp"} --delete-excluded / $backupdir/Latest/
if [ $? -eq 0 ]
then
	echo " "	
	echostamp "rSync Operation completed."
else
	echo " "
	echostamp "rSync Operation Failed. Terminating."
	failmsg
	exit 1
fi

echostamp "Starting TAR..."
echo " "

tar -czf $backupdir/system_backup_$backuptime.tgz -C $backupdir/Latest/ . 1>/dev/null 2>$backupdir/tar_errors.log

if [ $? -eq 0 ]
then
	echo " "
	echostamp "TARBall successfully created under $backupdir/system_backup_$backuptime.tgz"
	echostamp "Checking for old backups to delete..."
	find $backupdir/*.tgz -mtime +7 -print0 | xargs -0 rm -rfv
else
	echo " "
	echostamp "TARBall creation failure. Please consult $backupdir/tar_errors.log for more details."
	failmsg
	exit 1
fi
successmsg
