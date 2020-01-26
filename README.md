# borg


Рассмотрим простой пример создания бэкапа:

Скачиваем последний релизный бинарник на сервер бэкапа и машину, которую будем бэкапить, с официального репозитория:
    
      wget https://github.com/borgbackup/borg/releases/download/1.1.6/borg-linux64 -O /usr/local/bin/borg
      chmod +x /usr/local/bin/borg


 На сервере бэкапов создаём пользователя borg:

    	 adduser borg

  На клиенте генерируется SSH-ключ:

    	ssh-keygen
    	ssh-copy-id borg@IP_borg_server
    
		На клиенте и на сервере:
		
    	chown -R borg:borg ~borg/.ssh

  Инициализируем borg repo на сервере с клиента:

    /usr/local/bin/borg init -e none borg@IP_borg_server:MyBorgRepo


  Ключ -e служит для выбора метода шифрования репозиторияю. MyBorgRepo — это имя каталога, в котором будет borg repo (создавать его заранее не нужно — Borg всё сделает сам).
    
Запускаем первый бэкап с помощью Borg (на клиенте):

    /usr/local/bin/borg create --stats --list borg@IP_borg_server:MyBorgRepo::"MyFirstBackup-{now:%Y-%m-%d_%H:%M:%S}" /etc /root

    Про ключи:
		
        --stats и --list дают нам статистику по бэкапу и попавшим в него файлам;
        borg@IP_borg_server:MyBorgRepo — это наш сервер и каталог.
        ::"MyFirstBackup-{now:%Y-%m-%d_%H:%M:%S}" — это имя архива внутри репозитория. Оно произвольно, но мы придерживаемся формата Имя_бэкапа-timestamp (timestamp в формате Python).

Посмотреть, что же попало в наш бэкап! Список архивов внутри репозитория(на сервере):

	/usr/local/bin/borg list MyBorgRepo/

MyFirstBackup-2018-08-04_16:55:53    Sat, 2018-08-04 16:55:54 [89f7b5bccfb1ed2d72c8b84b1baf477a8220955c72e7fcf0ecc6cd5a9943d78d]

Смотрим список файлов:

	/usr/local/bin/borg list MyBorgRepo::MyFirstBackup-2018-08-04_16:55:53


Достаём файл из бэкапа (можно и весь каталог):

	/usr/local/bin/borg extract MyBorgRepo::MyFirstBackup-2018-08-04_16:55:53 etc/hostname


Для автоматизации запуска резервного копирования по расписанию, можно использовать cron. 
Для этого создаём директорию для логов:
        
        mkdir /var/log/borg

И добавляем скрипт резервного копирования в крон(backup.sh):


Для бэкапа через каждые 30 минут

        crontab -e
        30,59 * * * * /usr/local/bin/backup.sh > /dev/null 2>&1
        
Для бэкапа через каждые 10 минут

        crontab -e
        10,20,30,40,50,59 * * * * /usr/local/bin/backup.sh > /dev/null 2>&1
Для бэкапа каждый день 12 часов ночи

        crontab -e
        0 0 * * * /usr/local/bin/backup.sh > /dev/null 2>&1
