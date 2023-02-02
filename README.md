# server_1s

## Общее  
В качестве сервера 1С используется версия [8.3.22](https://releases.1c.ru/project/Platform83) и выше. Следует использовать вариант "Технологическая платформа 1С:Предприятия (64-bit) для Linux".  
В качестве базы данных используется [Postgresql для 1С](https://postgrespro.ru/). Следует использовать вариант "Postgres Pro Standard".  

Сервер разбит на 3 части:  
* База данных  
* Сервер 1с  
* Сервер активации  

Подразумивается, что каждый блок был установлен на разных виртуальных машинах. В случае, если планируется держать сервер на одной виртуальной машине, есть объединенный файл [docker-compouser](./docker-compose.yml) и [init](./init.sh) скрипт в корневой папке. Но такой режим рекомендуется использовать для тестовых целей.  
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
│   ├── healthcheck.sh
│   └── run.sh
├── root_srv1s
│   ├── healthcheck.sh
│   ├── srv1s.crt
│   └── srv1s.key
└── srvConfig
```  
___
## База данных  
#### Подготовка  
Для формирования начальных дирректорий и файлов выполнить:  
* ```chmod +x ./init.sh && ./init.sh```в случае запуска всех серверов на одном хосте.  
* ```cd ./pgsql1s && chmod +x ./init.sh && ./init.sh```в случае запуска pgsql на отдельном хосте.  

В, созданном скриптом, файле .env нужно отредактировать переменные:  

* TZ - Часовой пояс в формате Europe/Moscow  
* PASS - пароль пользователя postgres (Пароль хранится в открытом виде!)  
* SHEDULE - расписание выполнения бекапов в формате cron  

В результате выполнения скрипта на отдельном хосте формируется следующее дерево:  
```bash
/_1s/
├── backup
├── database
└── root_pgsql1s
    ├── backup.sh # Стоит осмотреть этот скрипт перед запуском сервера
    ├── healthcheck.sh
    └── run.sh
```  

#### Особенности обновления  
Для обновления нужно:  
* получить ссылку на новую версию на сайте [Postgresql для 1С](https://postgrespro.ru/)
* заменить ссылку в файле Dockerfile
* поправить пути, если изменилась старшая версия.  
___
## Сервер 1С
#### Подготовка  
1. Настройка файла [nethasp.ini](./srv1s/nethasp.ini)  
В случае работы серверов на одном хосте, файл настроен. Вслучае разделенных серверов, нужно указать ip сервера лицензий.  
2. Настройка файла [default-ssl.conf](./srv1s/apacheConf/default-ssl.conf)  
Нужно добавить разделы Directory в соответствии с правилами:
```bash
                ...
                Alias "/database1" "/var/www/1c/database1/" # Заменить database1 на имя публикуемой базы.
                <Directory "/var/www/1c/database1/">        # Тут тоже.
                        AllowOverride All
                        Options None
                        Require all granted
                        SetHandler 1c-application
                        ManagedApplicationDescriptor "/var/www/1c/database1/default.vrd" 
                                                # Файл публикации, находящийся в
                                                # /_1s/apacheDir/[Имя_Публикуемой_Базы]/default.vrd
                </Directory>
                ...
```
3. Настройка файлов [default.vrd](./srv1s/apacheDir/database1/default.vrd) и изменить имя родительсой папки на имя публикуемой базы как в пункте 2.  
4. Исправить файл сконфигурации [srv1s.conf](./srv1s/srv1s.conf).  
5. Сгенерировать файлы сертификатов  
```openssl req -x509 -nodes -days 4000 -newkey rsa:2048 -keyout /_1s/root_srv1s/srv1s.key -out /_1s/root_srv1s/srv1s.crt -config ./srv1s/srv1s.conf```  
7. Выполнить [init.sh](./srv1s/init.sh)
```cd ./srv1s && chmod +x ./init.sh && ./init.sh ```
В результате получится дерево хранилища:
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
├── root_srv1s
│   ├── healthcheck.sh
│   ├── srv1s.crt
│   └── srv1s.key
└── srvConfig
```

___
## Сервер лицензий
#### Подготовка  
Скачать недостающие файлы.  
В файле hasplm.conf поправить прослушиваемые ip, если нужно.  
___








