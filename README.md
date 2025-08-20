# создание ВМ
Создаем ВМ в Яндекс облаке
```bash
    yc compute instance create \
        --name ch-node \
        --ssh-key ~/.ssh/id_rsa.pub \
        --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-2204-lts,size=100,auto-delete=true \
        --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
        --memory 16G \
        --cores 4 \
        --zone ru-central1-a \
        --hostname ch-node
```

# установка Docker

```bash
    sudo apt-get update

    sudo apt-get install ca-certificates curl

    sudo install -m 0755 -d /etc/apt/keyrings

    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update

    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

# установка кликхауса
```bash
    grep -q sse4_2 /proc/cpuinfo && echo "SSE 4.2 supported" || echo "SSE 4.2 not supported"

    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates dirmngr

    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 8919F6BD2B48D754

    echo "deb https://packages.clickhouse.com/deb stable main" | sudo tee \
        /etc/apt/sources.list.d/clickhouse.list

    sudo apt-get update

    sudo apt-get install -y clickhouse-server clickhouse-client
```
Делаем доступным кликахус снаружи: создаем отдельный файл конфига:
```bash
    sudo su 
    vi /etc/clickhouse-server/config.d/listenhosts.xml
```
прописываем конфигурацию
```bash
    <clickhouse>
    <listen_host>0.0.0.0</listen_host>
    </clickhouse>
```
запускаем сервис
```bash
sudo service clickhouse-server start
sudo service clickhouse-server status
```

# установка postgresql
устанавливаем PostgreSQL
```bash
    sudo apt install postgresql postgresql-contrib

    sudo systemctl start postgresql.service

    sudo systemctl status postgresql.service
```
Авторизуемся для создания БД, роли и грантов
```bash
    sudo -i -u postgres

    psql

    CREATE USER admin WITH PASSWORD 'qwerty';

    CREATE DATABASE dev;

    GRANT ALL PRIVILEGES ON DATABASE dev TO admin;
```
При необходимости смены пароля
```bash
    ALTER USER admin WITH PASSWORD 'qwerty';
```
Делаем доступным снаружи
```bash
    sudo ufw allow 5432/tcp

    sudo su
    vi /etc/postgresql/14/main/pg_hba.conf
    host    all             all             0.0.0.0/0               md5
    vi /etc/postgresql/14/main/postgresql.conf
    listen_addresses = '*'
```

# Интеграция с postgresql
Создаем БД и 4 таблицы для интеграции
```bash
CREATE DATABASE dev

CREATE TABLE dev.users (id Int64, first_name String, last_name String, phone String,sex String,birth_date Date32)
ENGINE=PostgreSQL('localhost:5432','dev','users','admin','qwerty','scooters_raw')

CREATE TABLE dev.events (user_id Int64, timestamp DateTime64, type_id Int64)
ENGINE=PostgreSQL('localhost:5432','dev','events','admin','qwerty','scooters_raw')

CREATE TABLE dev.trips (id Int64, user_id Int64, scooter_hw_id String, started_at DateTime('Europe/Moscow'), finished_at DateTime('Europe/Moscow'), start_lat Float64 ,start_lon Float64 , finish_lat Float64 , finish_lon Float64 , distance Float64, price Int64)
ENGINE=PostgreSQL('localhost:5432','dev','trips','admin','qwerty','scooters_raw')

CREATE TABLE dev.users (id Int64, first_name String, last_name String, phone String,sex String,birth_date Date32)
ENGINE=PostgreSQL('localhost:5432','dev','users','admin','qwerty','scooters_raw')
```

# scooters_dbt

## Описание проекта

Проект на базе dbt, предназначенный для управления и трансформации данных,
связанных с использованием скутеров кикшеринга.
Позволяет выстроить аналитику данных о передвижениях и использовании скутеров.

## Быстрый старт

1. Убедитесь, что у вас установлен Python и pip:

```bash
python --version
pip --version
```

2. Установите dbt и адаптер postgres:
   
```bash
pip install dbt dbt-clickhouse
```

3. Клонируйте репозиторий, а затем перейдите в директорию проекта:

```bash
cd scooters_dbt
```

## Конфигурация

Обновите конфигурационный файл `~/.dbt/profiles.yml` с вашими данными доступа к базе данных.

## Основные команды dbt

- `dbt debug` - проверка подключения к хранилищу данных (проверка профиля)
- `dbt parse` - парсинг файлов проекта (проверка корректности)
- `dbt compile` - компилирует dbt-модели и создает SQL-файлы
- `dbt run` - материализация моделей в таблицы и представления
- `dbt test` - запускает тесты для проверки качества данных
- `dbt seed` - загружает данные в таблицы из CSV-файлов
- `dbt build` - основная команда, комбинирует run, test и seed
- `dbt docs generate` - генерирует документацию проекта
- `dbt docs serve` - запускает локальный сервер для просмотра документации

# устновка Apache Superset с использованием Docker
```bash
sudo docker pull apache/superset
sudo docker run -d -p 8080:8088 -e "SUPERSET_SECRET_KEY=your_secret_key_here" --name superset apache/superset

sudo docker exec -it superset superset fab create-admin \
 --username admin \
 --firstname Superset \
 --lastname Admin \
 --email admin@superset.com \
 --password admin
 
sudo docker exec -it superset superset db upgrade
sudo docker exec -it superset superset init

sudo docker ps
sudo docker exec -it <conteiner_id>  /bin/bash
pip install clickhouse-connect
exit
sudo docker restart <conteiner_id>
```

# настройка бекапирования
создание конфига для использования s3 диска в бакете яндекс клауда
```bash
sudo vi /etc/clickhouse-server/config.d/storage_config.xml
```
```bash
    <clickhouse>
    <storage_configuration>
            <disks>
                    <s3_disk>
                            <type>s3</type>
                            <endpoint>https://storage.yandexcloud.net/scooters-backet/</endpoint>
                            <access_key_id>необходимо сформировать ключ в я облаке</access_key_id>
                            <secret_access_key>секретный ключ отображается только один раз при создании</secret_access_key>
                            <metadata_path>/var/lib/clickhouse/disks/s3_disk/</metadata_path>
                    </s3_disk>
            </disks>
            <policies>
                    <s3_main>
                            <volumes>
                                    <main>
                                            <disk>s3_disk</disk>
                                    </main>
                            </volumes>
                    </s3_main>
            </policies>
    </storage_configuration>
    <backups>
            <allowed_disk>s3_disk</allowed_disk>
    </backups>
    </clickhouse>
```
примеры запросов для создания бэкапа на бакете яндекс клауда
```bash
BACKUP table dev.users TO Disk ('s3_disk','scooters-backet')
DROP TABLE dev.users
RESTORE TABLE dev.users FROM Disk('s3_disk', 'scooters')
```
# мониторинг
Создание таблицы для кастомных запросов
```bash
create table custom_dashboards
(
id UInt32,
title String,
query String
)
ENGINE=MergeTree()
ORDER BY id;
```
Примеры кастомных запросов
```bash
INSERT INTO custom_dashboards Values
(1, 'Количество запросов сгруппированных по пользователю в единицу времени','SELECT toStartOfInterval(event_time, INTERVAL{rounding:UInt32} SECOND)::INT as time,user String,count() as query_count FROM system.query_log WHERE event_date >= toDate(now() - {seconds:UInt32}) AND event_time >= now() - {seconds:UInt32} and type = 2 GROUP BY time, user ORDER BY time WITH FILL STEP {rounding:UInt32}'), 
(2, 'Количество пользователей за выбранное время','SELECT toStartOfInterval(event_time, INTERVAL{rounding:UInt32} SECOND)::INT as time, count(distinct user) as user_count FROM system.query_log WHERE event_date >= toDate(now() - {seconds:UInt32}) AND event_time >= now() - {seconds:UInt32} and type = 2 GROUP BY time ORDER BY time WITH FILL STEP {rounding:UInt32}'), 
(3, 'Вставка данных в килобайтах', 'SELECT toStartOfInterval(event_time, INTERVAL {rounding:UInt32} SECOND)::INT AS t, avg(ProfileEvent_InsertedBytes)/1024 AS inserted_kbytes  FROM system.metric_log WHERE event_date >= toDate(now() - {seconds:UInt32}) AND event_time >= now() - {seconds:UInt32} GROUP BY t ORDER BY t WITH FILL STEP {rounding:UInt32}')
```
необходимо авторизоваться на веб интерфесе и в строку поиска ввести запрос
```bash
SELECT title, query FROM merge(REGEXP('dashboards|system'),'custom_dashboards')
```