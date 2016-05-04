#!/bin/bash

#script to check Mysql replication is running

     primary=`mysql --user= --password= -e "show slave status\G" | grep -i " Master_Log_File:" | awk '{print $2}'`
    if [[ $primary != *"mysql-bin"* ]]
then
   exit 1
fi
    status=0
    MasterHost=`ssh@hostname hostname`
    SlaveHost="$HOSTNAME"
    emails="" #multiple emails space separated
    DownSubject="Replication status - Down"
    GoodSubject="Replication status - Good"
    GoodMessage="MySQL replication on $MasterHost and $SlaveHost is good"
    #Grab the lines for each and use awk to get the last part of the string(Yes/No)
    SQLresponse=`mysql --user= --password=  databasename -e "show slave status \G" |grep -i "Slave_SQL_Running"| awk '{print $2}'`
    IOresponse=`mysql  --user= --password=  databasename -e "show slave status \G" |grep -i "Slave_IO_Running" | awk '{print $2}'`
    if [ "$SQLresponse" = "No" ]; then
    error="Replication on the slave MySQL server($SlaveHost) has stopped working to ($MasterHost). Slave_SQL_Running not running:"
    status=1
    fi
    if [ "$IOresponse" = "No" ]; then
    error="Replication on the slave MySQL server($SlaveHost) has stopped working to ($MasterHost). Slave_IO_Running not running:"
    status=1
    fi
    # If the replication is not working
    if [ $status = 1 ]; then
    for address in $emails; do
    echo $error | mutt -s "$DownSubject" $address
    echo "Replication down, sent email to $address"
    done
    fi

    #If the replication is working fine
    #if [ $status = 0 ]; then
    #for address in $emails; do
    #echo  $GoodMessage | mutt -s "$GoodSubject" $address
    #echo "Replication is up, still sent email to $address"
    #done
    #fi
