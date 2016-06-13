#!/bin/bsah

#script to restore the database after a rebuld form live to test crm


#take a backup of the Live DB and copy it to the local path /mnt/data/restore/

echo 'Backing up Live Test DB at' `date`
echo ''
echo ''


        ssh emisuser@192.168.xx.xx  mysqldump --user=xxxx --password=xxxxx --single-transaction=TRUE --master-data=1 emis_sugarcrm > /mnt/data/restore/dump.sql

echo 'Backup taken'

#read out the logfile & postion and the dump file and write to a file

        cd /mnt/data/restore
        head -n 100 dump.sql | grep "CHANGE MASTER TO"  | awk {'print $4'}   > logfile
        head -n 100 dump.sql | grep "CHANGE MASTER TO"  | awk {'print $5'}   > position


LOGFILE="$(cat /mnt/data/restore/logfile)"
POSITION="$(cat /mnt/data/restore/position)"



echo 'Got logfile & position  from the backup dump file'
echo ''
echo ''

echo 'stopping and reseting slave'




                mysql --user=xxx --password=xxxx -e "stop slave; reset slave;"

echo ''
echo ''
echo ''

echo 'Check stop has been stopped and reset'

sleep 30

echo 'Importing dump.sql data file in to database'

                mysql --user=xxx --password=xxx  databasename < /mnt/data/restore/dump.sql

echo ''
echo 'Database restored on' `hostname` 'at' `date`
echo ''

#now we need to get the co-ordinates from the logfile and the postion"

                mysql --user=xxxx --password=xxxx -e "change master to $LOGFILE $POSITION"

echo 'Added in logfile and position'

echo ''

echo ''

                mysql --user=root --password=password -e "start slave;"

echo ''

echo 'Slave started'

              rm -fr /mnt/data/restore/dump.sql

echo 'Removed Dump.sql file'

exit 0
