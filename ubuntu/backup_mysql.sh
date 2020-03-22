docker exec 6bcff61d37d5 /usr/bin/mysqldump -umpoker --password=VpF3uQC3FdXxNzwy5Cy5Ldu93ayUBmej mpoker --no-data | gzip > /home/midas/backend/backup/mpoker_`date '+%d%m%Y'`_structure.sql.gz
docker exec 6bcff61d37d5 /usr/bin/mysqldump -umpoker --password=VpF3uQC3FdXxNzwy5Cy5Ldu93ayUBmej mpoker --ignore-table=mpoker.game_history --ignore-table=mpoker.game_leave_history | gzip > /home/midas/backend/backup/mpoker_`date '+%d%m%Y'`_data.sql.gz
mysqldump -u root -pPASSWORD database_name | gzip > /mnt/backup/mysql/database_name.`date '+%m-%d-%Y'`.sql.gz
