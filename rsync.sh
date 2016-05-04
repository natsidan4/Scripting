# --del removes files in the target directory that have been deleted from the source, resulting in a mirror of the source folder
# '/' at the end of the path means that the folder contents will be copied but not the folder itself

if [ -z "$1" ]; then
    echo 'usage: $0 <path to rysnc>'
    exit 1;
fi;

RSYNC_PATH=$1

email=""

echo 'Starting rsync process on' `hostname` 'at' `date`
echo ''
echo 'Syncing' ${RSYNC_PATH}
echo ''

rsync -avz --del \
    -e "ssh -i /home/user/.ssh/id_rsa" \
    --exclude='src/cache/.nfs*' \
    ${RSYNC_PATH} user@hostname:${RSYNC_PATH}

if [ "$?" -ne "0" ]; then
    echo ''
    echo '[Fail] Failed to sync, notifying relevant people'
    echo | mutt -s "Errors Occurred in Rsync on $(hostname) for ${RSYNC_PATH}" $email
    echo ''
    echo 'Email sent to: ' $email
fi

echo 'Finished running rsync process on' `hostname` 'at' `date`
echo '--'
echo ''
echo ''
exit 0
