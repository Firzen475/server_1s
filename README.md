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
    ├── distr
    │   └── server64_8_3_2X_XXXX.tar.gz
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
#### Загрузка
``` mkdir /server_1s && git clone https://github.com/Firzen475/server_1s.git /server_1s ```

___
## Сервер 1С
#### Подготовка  
1. Скачать нужную версию сервера  
В качестве сервера 1С используется версия [8.3.22](https://releases.1c.ru/project/Platform83) и выше. Следует использовать вариант "Технологическая платформа 1С:Предприятия (64-bit) для Linux".
2. Настройка файла [nethasp.ini](./srv1s/nethasp.ini)  
В случае работы серверов на одном хосте, файл настроен. Вслучае разделенных серверов, нужно указать ip сервера лицензий.  
3. Настройка файла [default-ssl.conf](./srv1s/apacheConf/default-ssl.conf)  
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
4. Настройка файлов [default.vrd](./srv1s/apacheDir/database1/default.vrd) и изменить имя родительсой папки на имя публикуемой базы как в пункте 2.  
5. Исправить файл сконфигурации [srv1s.conf](./srv1s/srv1s.conf).  
6. Сгенерировать файлы сертификатов  
```openssl req -x509 -nodes -days 4000 -newkey rsa:2048 -keyout /_1s/root_srv1s/srv1s.key -out /_1s/root_srv1s/srv1s.crt -config ./srv1s/srv1s.conf```  
7. Сгенерировать файл usr1cv8.keytab:
* Создать пользователя usr1cv8 в домене (имя пользователя должно совпадать с пользователем, от которого запущен сервер 1С)
* Создать usr1cv8.keytab на домене коммандой:  
``` ktpass.exe -princ usr1cv8/srv1s.example.local@EXAMPLE.LOCAL -mapuser usr1cv8 -pass password -out C:\usr1cv8.keytab -ptype KRB5_NT_PRINCIPAL ```  
где example.local заменить на имя домена.
* Поместить файл usr1cv8.keytab в папку ./srv1s/root_srv1s/
* Изменить [krb5.conf](./srv1s/krb5.conf) в соответствии с параметрами домена. 
9. Выполнить [init.sh](./srv1s/init.sh)
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
#### Особенности обновления  
Для обновления нужно:  
* Скачать новую версию сервера и поместить в папку [distr](./srv1s/distr/)  
В качестве сервера 1С используется версия [8.3.22](https://releases.1c.ru/project/Platform83) и выше. Следует использовать вариант "Технологическая платформа 1С:Предприятия (64-bit) для Linux".
* Может случиться что базы пропадут. ОНИ ОСТАЛИС НА СЕРВЕРЕ POSTGRESQL!  
При обновлении может произойти ситуация что базы исчезнут, чтобы это исправить, их нужно добавить вручную через консоль администрирования серверов. Для этого нужно знать их названия не сервере postgresql. =)
___
## Сервер лицензий
#### Подготовка  
Скачать недостающие файлы.  
В файле hasplm.conf поправить прослушиваемые ip, если нужно.  
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
___









