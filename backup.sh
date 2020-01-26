#!/usr/bin/env bash

##
## ������� ���������� ��������� ��� Borg
##

## ���� ������������ ������������� SSH-����,
## �� ��� ���� ���� �������:
# export BORG_RSH="ssh -i /home/userXY/.ssh/id_ed25519"

## ������ ����������� Borg ����� ������� � ����������
## ���������, ����� �� ������� ��� ��� ������ �������
# export BORG_PASSPHRASE="top_secret_passphrase"

##
## ������� ���������� ���������
##

LOG="/var/log/borg/backup.log"
BACKUP_USER="u602"
REPOSITORY_DIR="server1"

## �����: ��� ������������� Backup Space ������� ������������ �����
## 'your-storagebox.de" ������ "your-backup.de'

REPOSITORY="ssh://${BACKUP_USER}@${BACKUP_USER}.your-storagebox.de:23/./backups/${REPOSITORY_DIR}"

##
## ����� � ���� �������
##

exec > >(tee -i ${LOG})
exec 2>&1

echo "###### Backup started: $(date) ######"

##
## ����� ����� ��������� �������������� ��������
## ����� ��������� ��������� �����, ��������:
##
## - ������� ������ �������������� ������������ �����������
## - ������� ���� ���� ������
##

##
## �������� ������ � �����������.
## � ������ ������� ����� ����������� ����������
## root, etc, var/www � home.
## ����� ���� ������ ����������, ������� �� ������ �������
## � ��������� �����.
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