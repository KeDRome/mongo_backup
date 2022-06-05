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
    BACKUP_STORAGE=$BACKUP_STORAGE/$WDate.tar.gz
    check_storage
fi    

echo "[1.0] Восстановление.."
echo "[1.1] Создания каталога для извлечения архива ${BACKUP_STORAGE::-7}"
mkdir -p ${BACKUP_STORAGE::-7}
if [ $? -eq 0 ]; then
    echo "[1.1.+] Каталог создан успешно!" 
else
    echo "[1.1.-] Каталог не был создан! Вы root?"
    exit
fi 
echo "[1.2] Извлечение архива в ${BACKUP_STORAGE::-7}"
tar -xf $BACKUP_STORAGE -C $(echo ${BACKUP_STORAGE::-7}) 
if [ $? -eq 0 ]; then
    echo "[1.2.+] Извлечение успешно завершено!" 
else 
    echo "[1.2.-] Во время извлечения возникли ошибки! Проверьте, что во время транспортировки архива он не был поврежден!"
    exit
fi
BACKUP_STORAGE=${BACKUP_STORAGE::-7}
echo "[1.3] Восстановление из каталога $BACKUP_STORAGE.."
mongorestore --gzip --drop --dir=$BACKUP_STORAGE
if [ $? -eq 0 ]; then
    echo "[1.3.+] Восстановление успешно выполнено!";
else
    echo "[1.3.-] Во время восстановления возникли ошибки!"
    exit
fi