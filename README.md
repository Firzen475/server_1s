# server_1s

## Общее  
Сервер разбит на 3 части:  
* База данных  
* Сервер 1с  
* Сервер активации  

Подразумивается, что каждый блок был установлен на разных виртуальных машинах. В случае, если планируется держать сервер на одной виртуальной машине, есть объединенный файл [docker-compouser](./docker-compouser.yaml) и [init](./init.sh) скрипт в корневой папке. Но такой режим рекомендуется использовать для тестовых целей.

Все образы оснащены системой healthcheck. В случае сбоя сервера он может быть перезапущен с помощью внешних компонент (Kubernetes)

#### Дерево файлов  
```bash
/server_1s/  
├── README.md  
├── docker-compose.yml  
├── init.sh # Скрипт подготовки для единого сервера  
├── lic  
│   ├── Dockerfile  
│   ├── docker-compose.yml  
│   ├── entrypoint.sh  
│   ├── hasplm.conf  
│   └── healthcheck.sh  
├── pgsql1s  
│   ├── Dockerfile  
│   ├── docker-compose.yml  
│   ├── entrypoint.sh  
│   ├── init.sh # Скрипт подготовки для отдельного сервера pgsql  
│   └── root  
│       ├── backup.sh  
│       ├── healthcheck.sh  
│       └── run.sh  
└── srv1s  
    ├── Dockerfile  
    ├── apacheConf  
    │   └── default-ssl.conf  
    ├── apacheDir  
    │   ├── database1  
    │   │   └── default.vrd  
    │   ├── database2  
    │   │   └── default.vrd  
    │   └── database3  
    │       └── default.vrd  
    ├── docker-compose.yml  
    ├── entrypoint.sh  
    ├── init.sh # Скрипт подготовки для отдельного сервера 1C  
    ├── nethasp.ini  
    ├── root_srv1s  
    │   └── healthcheck.sh  
    └── srv1s.conf  
```  
#### Общее дерево хранилищь  
```bash
/_1s/
├── apacheConf
│   └── default-ssl.conf
├── apacheDir
│   ├── database1
│   │   └── default.vrd
│   ├── database2
│   │   └── default.vrd
│   └── database3
│       └── default.vrd
├── backup
├── database
├── root_pgsql1s
│   ├── backup.sh
│   ├── healscheck.sh
│   ├── healthcheck.sh
│   └── run.sh
├── root_srv1s
│   ├── healthcheck.sh
│   ├── srv1s.crt
│   └── srv1s.key
└── srvConfig
```  

## База данных  
#### Подготовка  
В качестве базы данных используется Postgresql для 1С(ссылка). 
Для формирования начальных дирректорий и файлов выполнить:  
* ```chmod +x ./init.sh && ./init.sh```в случае запуска всех серверов на одном хосте  
* ```cd ./pgsql1s && chmod +x ./init.sh && ./init.sh```в случае запуска pgsql на отдельном хосте  
Сервер принимает 3 переменные в файле .env:
TZ - Часовой пояс в формате Europe/Moscow
PASS - пароль пользователя postgres (Пароль хранится в открытом виде!)
SHEDULE - расписание выполнения бекапов в формате cron 
Сервер резервирует стандартный порт 5432.
Серверу требуются 3 директории:
/_1s/root - директория хранения cron скриптов
/_1s/database - файлы базы данных. Они вынесены из образа чтобы база не очищалась при пересборке образа.
/_1s/backup - место хранения бекапов. По умолчанию бекапы старше 3-х лет стераются.
 

#### Особенности обновления  
Для обновления нужно:
получить ссылку на новую версию на сайте Postgresql для 1С(ссылка)
заменить ссылку в файле Dockerfile
поправить пути, если изменилась старшая версия.  

## Сервер лицензий
#### Подготовка  
Скачать недостающие файлы.  
В файле hasplm.conf поправить прослушиваемые ip, если нужно.  
