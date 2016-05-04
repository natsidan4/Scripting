#!/bin/bash

#script to test if the web site is up


SITESFILE=sites.txt                                     #list the sites you want to monitor in this file
EMAIL="Gary.Williams@emishealth.com, Mark.Burn@emishealth.com, Frazer.Bradburn@emishealth.com"  #list of email addresses to receive alerts (comma separated)

echo 'Script excuting on' `hostname` 'at' `date`

while read site; do
    if [ ! -z "${site}" ]; then

        CURL=$(curl -s --head $site)

        if echo $CURL | grep "200 OK" > /dev/null
        then
            echo "Apache is serving up pages on  ${site} !"
        else

            MESSAGE="This is an alert!! Your Secondary site ${site} has failed to respond 200 OK Status."

            for EMAIL in $(echo $EMAIL | tr "," " "); do
                SUBJECT="$site (http) Failed"
                echo "$MESSAGE" | mutt -s "$SUBJECT" $EMAIL
                echo $SUBJECT
                echo "Alert sent to $EMAIL"
            done
        fi
    fi

echo 'Script completed on' `hostname` 'at' `date`

done < $SITESFILE