#!/bin/bsah

#script to restore the database after a rebuld form live to test crm


#Take a backup of the Live DB and copy it to the local path /mnt/data/restore/

EMAIL="Gary.Williams@emishealth.com"
MESSAGE="DB refresh script failed check DB status on (hostname)"

echo 'Backing up Live Test DB at' `date`
echo ''
echo ''


        ssh emisuser@crm-mysql-rep.emis.local \
        mysqldump --user=root --password=5ugarSQL --single-transaction=TRUE --master-data=1 \
        emis_sugarcrm > /mnt/data/restore/dump.sql

echo 'Backup Completed and file located in /mnt/nfs/restore/'

#Read out the logfile & postion from  the dump file and write to a file

        cd /mnt/data/restore
        head -n 100 dump.sql | grep "CHANGE MASTER TO"  | awk {'print $4'}   > logfile
        head -n 100 dump.sql | grep "CHANGE MASTER TO"  | awk {'print $5'}   > position


LOGFILE="$(cat /mnt/data/restore/logfile)"
POSITION="$(cat /mnt/data/restore/position)"



echo 'Got logfile & position from the backup dump file'

echo ''

echo ''

echo 'stopping and reseting slave'



sleep 20


                mysql --login-path=local -e "stop slave; reset slave;"

echo ''
echo ''
echo ''

echo 'Check Slave has been stopped and reset'

sleep 20


echo 'Importing dump.sql data file in to emis_sugarcrm database'

                mysql --login-path=local  emis_sugarcrm < /mnt/data/restore/dump.sql

echo ''
echo 'Database restored' `hostname` 'at' `date`
echo ''

#Now we need to get the co-ordinates from the logfile and the postion"

                mysql --login-path=local  -e "change master to $LOGFILE $POSITION"

echo 'Added in logfile and position'

echo ''

echo ''

                mysql --login-path=local  -e "start slave;"

echo ''

echo 'Slave started'

if [ "$?" = "0" ]; then

         rm -fr /mnt/data/restore/dump.sql
else
        echo "DB refresh script failed" | mutt -s $MESSAGE $EMAIL

        exit 1
fi


exit 0
