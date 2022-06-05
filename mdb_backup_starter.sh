#!/bin/bash
echo "####################################"
echo "#       MongoDB Backup Tool        #"
echo "####################################"
echo  "" 
CWDir=$( pwd )
CWUser=$( whoami )
CDate=$( date +%m.%d.%Y)

BACKUP_STORAGE=$1
BACKUP_STORAGE_bydefault='/backup'

check_storage(){
    echo "[0.2] Проверка существования.."
    cd $BACKUP_STORAGE && cd $CWDir
    if [ $? -eq 0 ]; then
        echo "[0.2.+] Каталог существует!" 
    else
        echo "[0.2.-] Каталог не существует! Попытка создать каталог..."
        mkdir -p $BACKUP_STORAGE
        if [ $? -eq 0 ]; then
            echo "[0.2.+] Каталог создан!"
        else
            echo "[0.2.-] Создать каталог не удалось! Вы root?"
            echo "[ERROR] Проверка хранилища прервана!"
            exit
        fi
    fi 
    echo "[0.3] Проверка прав доступа..."
    touch $BACKUP_STORAGE/check && rm -f $BACKUP_STORAGE/check && \
        if [ $? -eq 0 ]; then
            echo "[0.3.+] Прав доступа достаточно!"
            echo "[OK] Проверка хранилища успешно закончена!"
        else
            echo "[0.3.-] Прав доступа недостаточно! Попытка сменить владельца и права доступа..."
            chown $CWUser.$CWUser $BACKUP_STORAGE && chmod 765 $BACKUP_STORAGE
            if [ $? -eq 0 ]; then
                echo "[0.3.+] Прав доступа достаточно!"
                echo "[OK] Проверка хранилища успешно закончена!"
            else
                echo "[0.3.-] Сменить владельца или права доступа не удалось! Вы root?"
                echo "[ERROR] Проверка хранилища прервана!"
                exit
            fi
        fi
};

echo "[0.0] Хранилище"
if [[ $BACKUP_STORAGE == "d" ]]; then
    BACKUP_STORAGE=$BACKUP_STORAGE_bydefault
    echo "[0.1] Выбрано хранилище по умолчанию.. $BACKUP_STORAGE"
    check_storage
else
    echo "[0.1] Выбрано хранилище $BACKUP_STORAGE"
    check_storage
fi    

echo "[1.0] Резервная копия MongoDB"
BACKUP_STORAGE=$BACKUP_STORAGE/$CDate
echo "[1.1] Создаем каталог для бэкапа.. $BACKUP_STORAGE"
mkdir $BACKUP_STORAGE
if [ $? -eq 0 ]; then
    echo "[1.1.+] Каталог успешно создан!"
else 
    echo "[1.1.-] Каталог не был создан.."
    exit
fi

echo "[2.2] Создаем бэкап"
mongodump --gzip --out=$BACKUP_STORAGE 
if [ $? -eq 0 ]; then
    echo "[2.2.+] Резервная копия успешно создана!";
    echo "[2.3] Архивируем бэкап"
    cd $BACKUP_STORAGE
    tar -czf ../$CDate.tar.gz .
    if [ $? -eq 0 ]; then
        echo "[2.3.+] Архивирование успешно завершено!"
    else
        echo "[2.3.-] Во время архивирования возникли ошибки! Проверьте наличие свободного места в каталоге $BACKUP_STORAGE !"
    fi
    cd $CWDir
else
    echo "[2.2.-] Во время создания резервной копии возникли ошибки!"
    cd $CWDir
    exit
fi