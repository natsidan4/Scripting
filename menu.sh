#!bin/bash
#declare the colour functions

black() { echo "$(tput setaf 0)$*$(tput setaf 9)"; }
red() { echo "$(tput setaf 1)$*$(tput setaf 9)"; }
green() { echo "$(tput setaf 2)$*$(tput setaf 9)"; }
yellow() { echo "$(tput setaf 3)$*$(tput setaf 9)"; }
blue() { echo "$(tput setaf 4)$*$(tput setaf 9)"; }
magenta() { echo "$(tput setaf 5)$*$(tput setaf 9)"; }
cyan() { echo "$(tput setaf 6)$*$(tput setaf 9)"; }
white() { echo "$(tput setaf 7)$*$(tput setaf 9)"; }

trap '' 2

  while true
  do
  clear
  echo "======================================================================================================="
  green 					"Failover Option Menu for ECRM Test Service"
  echo "======================================================================================================="
  yellow "Enter 1 To Run the Documents Update script prior to failing over"
  green "Enter 2 To check the Primary and the Secondary documents directories contain the same number of files"		
  yellow  "Enter 3 To Stop Apache running on all the Web servers"
  green "Enter 4 To Check the Status of the Apache Web Service on all the Web Servers"
  yellow  "Enter 5 To Start the Apache Web Service on all the Web Servers"
  green  "Enter 6 To remove the crontab jobs on all the Web Servers"
  yellow "Enter 7 To Install the crontab jobs on all the Web Servers"
  green  "Enter 8 To view the crontab jobs on App01 Web Server"	
  yellow "Enter 9 To Stop MYSQL Service on the Primary Database Server"
  green  "Enter 10 To Start MYSQL Service on the Primary Database Server"
  yellow "Enter 11 To Restart MYSQL Serivce on the Primary Database Server"	
  green "Enter 12 To Check MYSQL Service Status on the Primary Database Server"
  yellow "Enter 13 To set MYSQL Read-Only Value to on in the /etc/mysql/my.cnf file"
  green "Enter 14 To set MYSQL Read-Only Value to off in the /etc/mysql/my.cnf file"			
  yellow "Enter 15 To view MYSQL Read-Only Value in the /etc/mysql/my.cnf file "
  green "Enter 16 To check the MYSQL processlist on the Primary Database Server & The Slave Database Status"
  yellow "Enter 17 To exit the Menu"

    echo -e "\n"
    white "Enter your selection now"
    read answer
    case "$answer" in 
1)
	sudo -S bash /mnt/nfs/web/crm/scripts/platform/common/rsync.sh /mnt/nfs/web/ <~/include  > ~/tmp.txt | tail -n10 ~/tmp.txt
;;
	
2)
      doc01=`ls -l /home/emisuser/ | wc -l`
      doc02=`ssh emisuser@192.168.96.88 ls -l /home/emisuser/ |wc -l`	
      blue "Primary Docs have $doc01"
      blue "Secondary Docs have $doc02"
if [ "$doc01" == "$doc02" ]; then
 	green "Documents are in Sync "
	else
 	red "Documents are not in Sync "
	echo -e "\n"
fi	
	 		 
;;

3) 	sudo -S service apache2 stop < ~/include
	ssh emisuser@192.168.96.88 sudo -S service apache2 stop < ~/include
;;
4) 
	app01=`service apache2 status | awk '{print $3}'`
	app02=`ssh emisuser@192.168.96.88 service apache2 status | awk '{print $3}'`
if [ "$app01"  = "running" ]; then 
	green "Apache is running on SF-ECRM-TEST-APP01"
elif [ "$app01" = "NOT" ]; then
	red  "Apache is not running on SF-ECRM-TEST-APP01"
fi
if [ "$app02" = "running" ]; then
	green "Apache is running on SF-ECRM-TEST-APP02"
elif [ "$app02" = "NOT" ]; then
	red "Apache is not running on SF-ECRM-TEST-APP02" 
	
fi 
;;
5)
	sudo -S service apache2 start < ~/include
        ssh emisuser@192.168.96.88 sudo -S service apache2 start < ~/include
;;
6)
	crontab -r < ~/include
;;
7)
	crontab /mnt/nfs/web/crm/scripts/cron/crontab-master.test < ~/include 
;;
8)
	crontab -l < ~/include


;;
9)
	echo "Stopping MYSQL service on SF-ECRM-TEST-DB"
	ssh emisuser@192.168.96.89 "sudo -S service mysql stop" < ~/include
if 	[ "$?" = "0" ]; then
	echo "Mysql Service has stopped on SF-ECRM-TEST-DB"
fi

;;
10)
       echo "Starting MYSQL service on SF-ECRM-TEST-DB"	
       ssh emisuser@192.168.96.89 "sudo -S service mysql start" < ~/include
if      [ "$?" = "0" ]; then
        echo "Mysql Service has started on SF-ECRM-TEST-DB"
fi

;;
11)

      echo "Restart MYSQL service on SF-ECRM-TEST-DB"
       ssh emisuser@192.168.96.89 "sudo -S service mysql restart" < ~/include

if      [ "$?" = "0" ]; then
        echo "Mysql Service has Restarted on SF-ECRM-TEST-DB"
fi

;;
12)

	mysql=`ssh emisuser@192.168.96.89 "service mysql status" | awk '{print $2}'`
        if [ "$mysql" = "start/running," ]; then
                green "SF-ECRM-TEST-DB MYSQL Service is running"
        else
                red "SF-ECRM-TEST-DB MYSQL Service is NOT running"
        fi

;;
13)
	echo "Setting SF-ECRM-TEST-DB to Read-Only"
	ssh emisuser@192.168.96.89 "sudo -S sed -i "s/read-only=0/read-only=1/" /etc/gary.cnf" < ~/include
if [ "$?" = "0" ]; then
	echo "SF-ECRM-TEST-DB set to Read-only"
else
	echo "Read only NOT set"
fi
;;


14)
	ssh emisuser@192.168.96.89 "sudo -S sed -i "s/read-only=1/read-only=0/" /etc/gary.cnf" < ~/include

;;


15)
	ssh emisuser@192.168.96.89 "cat /etc/gary.cnf | grep read-only" 

;;

16)
	mysql --host=192.168.96.89 --user emisuser --password=T3ster -e "show processlist" | grep binlog

;;

17)
	exit
;;
esac
 echo -e "Enter Return to continue"
 read input 
done  
