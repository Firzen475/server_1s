# server_1s

## Описание  
Для работы hasp+ ключей нужен сервер не выше версии [Ubuntu 20.04](https://releases.ubuntu.com/focal/ubuntu-20.04.5-live-server-amd64.iso), на более новых версиях тесты не проводились.  
В качестве сервера 1С используется версия [8.3.22](https://releases.1c.ru/project/Platform83) и выше. Следует скачать вариант "Технологическая платформа 1С:Предприятия (64-bit) для Linux".  
В качестве базы данных используется [Postgresql для 1С](https://postgrespro.ru/). Следует использовать вариант "Postgres Pro Standard".  
Все образы оснащены системой healthcheck. В случае сбоя сервера он может быть перезапущен с помощью внешних компонент (Kubernetes).  
___
## Подготовка сервеов  
Следующий набор комманд устанавливает [Docker](https://docs.docker.com/engine/install/), [Docker-compouser](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-ubuntu-20-04-ru), и скачивает проект с [github]().  
```bash
sudo apt-get update && \
sudo apt-get install -y ca-certificates curl gnupg lsb-release && \
sudo mkdir -m 0755 -p /etc/apt/keyrings && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
sudo chmod +x /usr/local/bin/docker-compose && \
mkdir /server_1s/ && git clone https://github.com/Firzen475/server_1s.git /server_1s && cd /server_1s && mkdir -p /server_1s/srv1s/distr/
```  
```mv /home/user/hasp.zip ./ && mv /home/user/usr1cv8.keytab ./srv1s/root_srv1s/ && mv /home/user/server64* /server_1s/srv1s/distr/```  
Получаем следующую структуру файлов:  
```bash

```
#### Сервер 1С  
1. Настройка файла [default-ssl.conf](./srv1s/apacheConf/default-ssl.conf)  
Нужно добавить разделы Directory в соответствии с правилами:
```bash
                ...
                Alias "/databaseX" "/var/www/1c/databaseX/" # Заменить databaseX на имя публикуемой базы.
                <Directory "/var/www/1c/databaseX/">        # Тут тоже.
                        AllowOverride None
                        Options None
                        Order allow,deny
                        Allow from all
                        AuthName "1C:Enterprise web client"
                        AuthType Kerberos
                        Krb5Keytab /srvConfig/usr1cv8.keytab
                        KrbVerifyKDC off
                        KrbDelegateBasic off
                        KrbServiceName Any
                        KrbSaveCredentials on
                        KrbMethodK5Passwd off
                        KrbMethodNegotiate on
                        Require valid-user
                        SetHandler 1c-application
                        ManagedApplicationDescriptor "/var/www/1c/databaseX/default.vrd" 
                                                # Файл публикации на хосте, находящийся в
                                                # /_1s/apacheDir/databaseX/default.vrd
                </Directory>
                ...
```  

2. В папке [apacheDir](./srv1s/apacheDir/) переименовать папки "databaseX" в соответствии с именами публикуемых баз в пункте 2. В файлах [default.vrd](./srv1s/apacheDir/database1/default.vrd) изменить строки:  
```
                base="/databaseX"
                ib="Srvr=&quot;srv1s&quot;;Ref=&quot;databaseX&quot;;">
```  
на имя публикуемой базы.  

3. Сгенерировать файл usr1cv8.keytab:  
* Создать пользователя usr1cv8 в домене  
* Создать usr1cv8.keytab на домене последовательностью команд:  
```bash 
ktpass.exe /crypto ALL /princ usr1cv8/srv1s.example.com@EXAMPLE.COM /mapuser usr1cv8 /pass Password /out C:\usr1cv8_tmp.keytab /ptype KRB5_NT_PRINCIPAL
ktpass.exe /crypto ALL /princ HTTP/srv1s.example.com@EXAMPLE.COM /mapuser usr1cv8 /pass Password /in C:\usr1cv8_tmp.keytab /out C:\usr1cv8.keytab /ptype KRB5_NT_PRINCIPAL -setupn -setpass
```  
где example.com и EXAMPLE.COM заменить на имя домена.  
* Поместить файл usr1cv8.keytab в папку ./srv1s/root_srv1s/  
  
4. На хосте выполнить комманду:  
```chmod +x ./init.sh && ./init.sh [dc_name] [domain_name] [hasp_zip_password]```  
* [dc_name]-имя контроллера домена  
* [domain_name]-название домена  
* [hasp_zip_password]-пароль от архива hasp.zip (Архив должен быть скопирован в /server_1s)  

5. Скачать нужную версию сервера и закинуть в папку [distr](./srv1s/distr/)  
В качестве сервера 1С используется версия [8.3.22](https://releases.1c.ru/project/Platform83) и выше. Следует использовать вариант "Технологическая платформа 1С:Предприятия (64-bit) для Linux".  
  
В результате выполнения скрипта на отдельном хосте формируется следующее дерево:  
```bash

```  
___
#### Сервер Postgresql  
1. На хосте выполнить комманду:
```chmod +x ./init.sh && ./init.sh pgsql1s```  
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
___

## Запуск контейнеров  
#### Вариант для раздельных серверов (рекомендованный)  
###### Сервер 1С  
1. В файле ./srv1s/.env установить часовой пояс:
```nano ./srv1s/.env```  
2. Перейти в папку srv1s:
```cd ./srv1s/```  
3. Запустить контейнер:  
```docker-compose down && docker-compose build --force-rm && docker-compose up -d```  
###### Сервер Postgresql  
1. В файле ./srv1s/.env установить переменные:
```nano ./srv1s/.env```  
* TZ - Часовой пояс в формате Europe/Moscow  
* PASS - пароль пользователя postgres (Пароль хранится в открытом виде!)  
* SHEDULE - расписание выполнения бекапов в формате cron  
2. Перейти в папку srv1s:
```cd ./srv1s/```  
3. Запустить контейнер:  
```docker-compose down && docker-compose build --force-rm && docker-compose up -d```  

#### Вариант для одного сервера (тестирование) 
1. В файле ./srv1s/.env установить переменные:
```nano ./.env```  
* TZ - Часовой пояс в формате Europe/Moscow  
* PASS - пароль пользователя postgres (Пароль хранится в открытом виде!)  
* SHEDULE - расписание выполнения бекапов в формате cron  
2. Запустить контейнер:  
```docker-compose down && docker-compose build --force-rm && docker-compose up -d```  

## Обновление
#### 1C  
Для обновления нужно:  
* Скачать новую версию сервера и поместить в папку [distr](./srv1s/distr/)  
В качестве сервера 1С используется версия [8.3.22](https://releases.1c.ru/project/Platform83) и выше. Следует использовать вариант "Технологическая платформа 1С:Предприятия (64-bit) для Linux".  
* Если после обновления базы пропали, нужно добавить их с помощью консоли администрирования. Названия можно получить на сервере pgsql1s:  
```bash

```  
#### Postgresql  
Для обновления нужно:  
* получить ссылку на новую версию на сайте [Postgresql для 1С](https://postgrespro.ru/)
* заменить ссылку в файле Dockerfile




