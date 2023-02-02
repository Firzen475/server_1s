# server_1s

## Общее  
Сервер разбит на 3 части:
База данных
Сервер 1с
Сервер активации

Это нужно чтобы каждый блок был установлен на разных виртуальных машинах. В случае, если планируется держать сервер на одной виртуальной машине, есть объединенный файл docker-compouser и init скрипт в корневой папке. Но такой режим рекомендуется использовать для тестовых целей.

Все образы оснащены системой healthcheck. В случае сбоя сервера он может быть перезапущен с помощью внешних компонент (Kubernetes)

#### Дерево файлов  
/server_1s/  
├── README.md  
├── docker-compose.yml  
├── init.sh  
├── lic  
│   ├── Dockerfile  
│   ├── docker-compose.yml  
│   ├── entrypoint.sh  
│   ├── hasplm.conf  
│   └── healthcheck.sh  
├── pgsql1s  
│   ├── Dockerfile  
│   ├── docker-compose.yml  
│   ├── entrypoint.sh  
│   ├── init.sh  
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
    ├── init.sh  
    ├── nethasp.ini  
    ├── root_srv1s  
    │   └── healthcheck.sh  
    └── srv1s.conf  



## База данных  
#### Подготовка  
В качестве базы данных используется Postgresql для 1С(ссылка). 
Сервер принимает 3 переменные в файле .env:
TZ - Часовой пояс в формате Europe/Moscow
PASS - пароль пользователя postgres (Пароль хранится в открытом виде!)
SHEDULE - расписание выполнения бекапов в формате cron 
Сервер резервирует стандартный порт 5432.
Серверу требуются 3 директории:
/_1s/root - директория хранения cron скриптов
/_1s/bd - файлы базы данных. Они вынесены из образа чтобы база не очищалась при пересборке образа.
/_1s/backup - место хранения бекапов. По умолчанию бекапы старше 3-х лет стераются.
Для подготовки папок и файлов можно использовать init.sh скрипт в папке pgsql1s.
chmod +x ./init.sh && init.sh

#### Особенности обновления  
Для обновления нужно:
получить ссылку на новую версию на сайте Postgresql для 1С(ссылка)
заменить ссылку в файле Dockerfile
поправить пути, если изменилась старшая версия.
