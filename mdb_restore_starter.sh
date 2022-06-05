#!/bin/bash
echo "####################################"
echo "#      MongoDB Restore Tool        #"
echo "####################################"
echo  ""

CWDir=$( pwd )
CWUser=$( whoami )
WDate=$2

BACKUP_STORAGE=$1
BACKUP_STORAGE_bydefault='/backup'

check_storage(){
    echo "[0.2] Проверка существования.."
    touch $BACKUP_STORAGE 
    if [ $? -eq 0 ]; then
        echo "[0.2.+] Бэкап существует!" 
    else
        echo "[0.2.-] Бэкап не существует! Вы правильно указали путь? Проверьте права доступа к каталогу!"
        exit
    fi 
};

echo "[0.0] Хранилище"
if [[ $BACKUP_STORAGE == "d" ]]; then
    BACKUP_STORAGE=$BACKUP_STORAGE_bydefault/$WDate.gz
    echo "[0.1] Выбрано хранилище по умолчанию.. $BACKUP_STORAGE"
    check_storage
else
    echo "[0.1] Выбрано хранилище $BACKUP_STORAGE"
    BACKUP_STORAGE=$BACKUP_STORAGE/$WDate.gz
    check_storage
fi    

echo "[1.0] Восстановление.."
mongorestore --nsInclude --gzip --drop --archive=$BACKUP_STORAGE
if [ $? -eq 0 ]; then
    echo "[1.1.+] Восстановление успешно выполнено!";
else
    echo "[1.1.-] Во время восстановления возникли ошибки!"
    exit
fi