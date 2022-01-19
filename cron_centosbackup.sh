#!/bin/bash

# Cron Executable Wrapper Script for Backup

./centosbackup.sh > latest_centos_backuplog.txt 

if [ $? -eq 0 ]
then
  exit 0
else
  mail -s "[WARN] CentOS Backup Failure!" jonlee@plan-ex.net < latest_centos_backuplog.txt
  exit 1
fi


