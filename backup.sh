#!/usr/bin/env bash

##
## «адание переменных окружени€ дл€ Borg
##

## если используетс€ нестандартный SSH-ключ,
## то его надо €вно указать:
# export BORG_RSH="ssh -i /home/userXY/.ssh/id_ed25519"

## пароль репозитори€ Borg можно указать в переменной
## окружени€, чтобы не вводить его при каждом запуске
# export BORG_PASSPHRASE="top_secret_passphrase"

##
## «адание переменных окружени€
##

LOG="/var/log/borg/backup.log"
BACKUP_USER="u602"
REPOSITORY_DIR="server1"

## —овет: при использовании Backup Space следует использовать домен
## 'your-storagebox.de" вместо "your-backup.de'

REPOSITORY="ssh://${BACKUP_USER}@${BACKUP_USER}.your-storagebox.de:23/./backups/${REPOSITORY_DIR}"

##
## ¬ывод в файл журнала
##

exec > >(tee -i ${LOG})
exec 2>&1

echo "###### Backup started: $(date) ######"

##
## «десь можно выполнить дополнительные действи€
## перед созданием резервной копии, например:
##
## - сделать список установленного программного обеспечени€
## - сделать дамп базы данных
##

##
## ѕередача файлов в репозиторий.
## ¬ данном примере будут скопированы директории
## root, etc, var/www и home.
## “акже есть список исключений, который не должен входить
## в резервную копию.
##

echo "Transfer files ..."
borg create -v --stats                   \
    $REPOSITORY::'{now:%Y-%m-%d_%H:%M}'  \
    /root                                \
    /etc                                 \
    /var/www                             \
    /home                                \
    --exclude /dev                       \
    --exclude /proc                      \
    --exclude /sys                       \
    --exclude /var/run                   \
    --exclude /run                       \
    --exclude /lost+found                \
    --exclude /mnt                       \
    --exclude /var/lib/lxcfs

echo "###### Backup ended: $(date) ######"