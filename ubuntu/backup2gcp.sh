#!/bin/sh

# Updates etc at: https://github.com/mvarrieur/MySQL-backup-to-Google-Cloud-Storage
# Under a MIT license

# change these variables to what you need
MYSQLROOT=root
MYSQLPASS=123456
MYSQLHOST=127.0.0.1
MYSQLPORT=3306
GSBUCKET=bucket_name
FILENAME=dump_file_name
DATABASE=db_name
IGNORE_TABLES=''
# the following line prefixes the backups with the defined directory. it must be blank or end with a /
GSPATH=
# when running via cron, the PATHs MIGHT be different. If you have a custom/manual MYSQL install, you should set this manually like MYSQLDUMPPATH=/usr/local/mysql/bin/
MYSQLDUMPPATH=
# Change this if your gsutil is installed somewhere different.
GSUTILPATH=/usr/bin/
#tmp path.
TMP_PATH=~/
DATESTAMP=$(date +"_%m-%d-%Y_%H%M%S")
PERIOD=day
PERIOD_LIMIT=3
PROJECT_ID=midas-259007

echo "Starting backing up the database to a file..."
# dump all databases
${MYSQLDUMPPATH}mysqldump --host=${MYSQLHOST} --port=${MYSQLPORT} --user=${MYSQLROOT} --password=${MYSQLPASS} --no-data ${DATABASE} ${IGNORE_TABLES} > ${TMP_PATH}${FILENAME}_structure.sql
${MYSQLDUMPPATH}mysqldump --host=${MYSQLHOST} --port=${MYSQLPORT} --user=${MYSQLROOT} --password=${MYSQLPASS} ${DATABASE}  ${IGNORE_TABLES} > ${TMP_PATH}${FILENAME}_data.sql
echo "Done backing up the database to a file."

#compression...
echo "Starting compression..."
tar czf ${TMP_PATH}${FILENAME}${DATESTAMP}_structure.tar.gz ${TMP_PATH}${FILENAME}_structure.sql
tar czf ${TMP_PATH}${FILENAME}${DATESTAMP}_data.tar.gz ${TMP_PATH}${FILENAME}_data.sql
echo "Done compressing the backup file."

echo "Moving the backup from past $PERIOD to another folder..."
# ${GSUTILPATH}gsutil mv gs://${GSBUCKET}/${GSPATH}pre_${PERIOD_LIMIT}_${PERIOD}/ gs://${GSBUCKET}/${GSPATH}old_${PERIOD}/

for (( i = $PERIOD_LIMIT; i > 1; i-- )); do
  ${GSUTILPATH}gsutil mv gs://${GSBUCKET}/${GSPATH}pre_$(($i-1))_${PERIOD}/* gs://${GSBUCKET}/${GSPATH}pre_${i}_${PERIOD}/
#  echo ${GSUTILPATH}gsutil mv gs://${GSBUCKET}/${GSPATH}pre_$(($i-1))_${PERIOD}/ gs://${GSBUCKET}/${GSPATH}pre_${i}_${PERIOD}/
done

 ${GSUTILPATH}gsutil mv gs://${GSBUCKET}/${GSPATH}${PERIOD}/* gs://${GSBUCKET}/${GSPATH}pre_1_${PERIOD}/
# echo ${GSUTILPATH}gsutil mv gs://${GSBUCKET}/${GSPATH}${PERIOD}/ gs://${GSBUCKET}/${GSPATH}pre_1_${PERIOD}/
echo "Past backup moved."

# upload all databases
echo "Uploading the new backup..."
${GSUTILPATH}gsutil cp ${TMP_PATH}${FILENAME}${DATESTAMP}_structure.tar.gz gs://${GSBUCKET}/${GSPATH}${PERIOD}/
${GSUTILPATH}gsutil cp ${TMP_PATH}${FILENAME}${DATESTAMP}_data.tar.gz gs://${GSBUCKET}/${GSPATH}${PERIOD}/
echo "New backup uploaded."

echo "Removing the cache files..."
# remove databases dump
rm ${TMP_PATH}${FILENAME}_structure.sql
rm ${TMP_PATH}${FILENAME}${DATESTAMP}_structure.tar.gz
rm ${TMP_PATH}${FILENAME}_data.sql
rm ${TMP_PATH}${FILENAME}${DATESTAMP}_data.tar.gz
echo "Files removed."
echo "All done."
