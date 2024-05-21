# Основы Docker. Создание образа и запуск контейнера

## Оглавление

1. [Структура папок](#структура-папок)
2. [Python сервер](#python-сервер)
3. [Dockerfile](#dockerfile)
4. [.gitignore](#gitignore)
5. [requirements.txt](#requirements)
6. [Базовые команды для докера](#базовые-команды-для-докера)
7. [Сборка образов докера](#работа-с-образами-докера)
8. [Запуск контейнеров докера](#работа-с-контейнерами-докера)
9. [Непосредственно тест](#непосредственно-тест)

## Комментарий

Вся информация, предоставленная в данном топике, дублируется в официальной документации докера, которую можно посмотреть [по этой ссылке](https://docs.docker.com/engine/)

## Структура папок

Структура папок в нашем случае будет упрощённой, чем может быть на проекте. Главное правило - разделять сущности. К примеру в данном варианте у нас отдельно находится **Dockerfile** и отдельно находятся исходники проекта (**src**). 

На более крупных проектах архитектура может быть другой, с примером можно ознакомиться по [этой ссылке](https://www.cosmicpython.com/book/appendix_project_structure.html).

```
├── Dockerfile
└── src
    ├── PyWebListener.py
    └── requirements.txt
```

### Дерево папок

Чтобы в консоли вывести дерево папок таким же красивым образом, как и в нашем примере, необходимо установить утилиту `tree`.

Для **linux** можно использовать следующую команду:

`sudo apt-get install tree`

После чего использовать утилиту в желаемой папке для демонстрации внутренней иерархии.

## Python сервер

У нас есть предоставленный разработчиком стандартный сервер на питоне, который занимается прослушиванием запросов и показом структуры и содержимого папок по адресу сервера. Мы будем использовать его как пример, потому что для докера он простой, немного жрёт, а также использует порты, с которыми нужно будет разобраться.

Сам код сервера:

```py
# Импортируем модуль для создания HTTP сервера, 
# для работы с сокетами и серверами, 
# для работы с операционной системой
import http.server  
import socketserver  
import os  

# Устанавливаем порт, на котором будет работать сервер. В данном случае это порт 80, стандартный порт для HTTP
PORT = 80  

# Определяем обработчик HTTP-запросов, который будет использоваться нашим сервером. SimpleHTTPRequestHandler обрабатывает только запросы GET и HEAD, а большего нам не надо
Handler = http.server.SimpleHTTPRequestHandler

# Создаем объект TCP сервера, который будет прослушивать указанный порт.
# Пустая строка "" означает, что сервер будет принимать запросы на всех доступных сетевых интерфейсах (всех IP-адресах).
httpd = socketserver.TCPServer(("", PORT), Handler)

# Выполняем команду операционной системы с помощью os.system. В данном случае выводим сообщение, что сервер работает на указанном порту
os.system("echo 'serving at port {}'".format(PORT))

# Запускаем сервер в бесконечный цикл, в течение которого он будет обрабатывать все входящие HTTP-запросы
httpd.serve_forever()
```

Согласно структуре папок, его нужно положить в папку **src**

## Dockerfile

```sh
# Подгружаем базовый образ контейнера, сделанный под python:3.5
FROM python:3.5

# Переходим в рабочую директорию **внутри образа** где будем запускаться код
WORKDIR /app

# Если у проекта есть библиотеки или зависимости (например библиотека scikit), то они указываются в файле requirements.txt, а следующие две строки надо раскомментить
# COPY src/requirements.txt ./
# RUN pip install -r requirements.txt

# Копирует содержимое папки с исходниками внутрь рабочей директории образа
COPY src /app

# Данная инструкция указывает, какие порты будут прослушиваться контейнером во время его работы. Без этой команды мы не сможем обратиться к веб-серверу, который упоминали ранее
EXPOSE 80

# Запускает сам код
CMD [ "python", "PyWebListener.py" ]
```

1. Команда **FROM** подгружает общедоступный контейнер по тегу. Каждый контейнер собирается со своими условиями под свои нужды. Если есть интерес посмотреть, как собирается наш контейнер, то можно перейти [по этой ссылке](https://hub.docker.com/layers/library/python/3.5/images/sha256-24d62b9e24e5b601b524f33a1d477a66fce675efe11c96dd163c0f0ce5cc9810?context=explore). Другие образы также можно найти у них на сайте
2. Все контейнеры с **python** имеют внутри себя небольшой **linux** со знакомой структурой файловой системы. Если мы не укажем через **WORKDIR** где мы будем работать, наш код будет лежать запускаться из кем-то заданного места, а с помощью COPY мы копируем его в /app. Оно просто не заработает 
3. Уже немного говорилось о requirements.txt, но это не всё, конечно же. Эти "необходимости" потом копируются внутрь образа, после чего в процессе сборки устанавливается всё содержимое requirements.txt, строчка за строчкой (командой **RUN pip install**)
4. Другой пример Dockerfile можно посмотреть [по этой ссылке](https://gist.github.com/jamtur01/6147676)
5. Больше про Dockerfile можно узнать [здесь](https://docs.docker.com/reference/dockerfile/) 

Согласно структуре папок, Dockerfile хранится в корне проекта

## .gitignore

Особенности работы с гитом это отдельная тема. Если кратко, файл .gitignore указывает, какие файлы и папки нужно игнорировать и не добавлять в репозиторий. Сюда мы добавили, что не нужно добавлять в репозиторий окружение, ну и просто для примера. 

```
.idea/

# dotenv
.env

# virtualenv
.venv
venv/
ENV/
```

Согласно структуре папок, .gitignore хранится в корне проекта

## requirements

Он же файл requirements.txt

В нашем случае файл пустой, но иногда он может выглядеть вот так: 

```
Flask>=0.10.1
Flask-Login>=0.3.2
PyJWT>=1.4.0
cryptography
requests==2.8.1
responses==0.5.0
nose==1.3.7
mock==1.3.0
gunicorn>=19.3.0
```

## Базовые команды для докера

Для начала, докер нужно установить:

`sudo apt-get install docker.io`

Также желательно установить Docker Desktop, если у тебя рабочая станция, и/или Docker Engine, если для сервера. В нашем примере мы используем Docker Engine (docker.io в нашем случае), или консольные команды если очень просто

### Работа с образами докера

#### docker build

Данная команда собирает образ по инструкциям в Dockerfile

Обычно команда docker build используется с точкой, обозначающей где искать Dockerfile (точка = в данной папке)

Пример работы

```
root@polygon:/home/user/DockerTest# docker build .
DEPRECATED: The legacy builder is deprecated and will be removed in a future rel                                                   ease.
            Install the buildx component to build images with BuildKit:
            https://docs.docker.com/go/buildx/

Sending build context to Docker daemon  14.34kB
Step 1/5 : FROM python:3.5
3.5: Pulling from library/python
57df1a1f1ad8: Pull complete
71e126169501: Pull complete
1af28a55c3f3: Pull complete
03f1c9932170: Pull complete
65b3db15f518: Pull complete
850581be87f3: Pull complete
1e37775630ae: Pull complete
7e054ca5fcba: Pull complete
92a0fe226896: Pull complete
Digest: sha256:42a37d6b8c00b186bdfb2b620fa8023eb775b3eb3a768fd3c2e421964eee9665
Status: Downloaded newer image for python:3.5
 ---> 3687eb5ea744
Step 2/5 : WORKDIR /app
 ---> Running in 606827425f31
Removing intermediate container 606827425f31
 ---> 9240718a7f48
Step 3/5 : COPY src /app
 ---> fadc92ef077e
Step 4/5 : EXPOSE 80
 ---> Running in 860e698c0d62
Removing intermediate container 860e698c0d62
 ---> cd6cca0e5a23
Step 5/5 : CMD [ "python", "PyWebListener.py" ]
 ---> Running in 22794fdced75
Removing intermediate container 22794fdced75
 ---> 56248aaa6ea0
Successfully built 56248aaa6ea0
```

Команду docker images мы разберём чуть позже, но результат выполнения этой команды будет выглядеть примерно так:

```
root@polygon:/home/user/DockerTest# docker images
REPOSITORY   TAG       IMAGE ID       CREATED              SIZE
<none>       <none>    56248aaa6ea0   About a minute ago   871MB
python       3.5       3687eb5ea744   3 years ago          871MB
```

Поскольку у нас REPOSITORY и TAG не имеют данных, они были обозваны системой как <none>. Чтобы избежать последующей путаницы в куче докер образов, при сборке используется флаг `-t`, как в этом примере:

`docker build . -t weblistener`

И результат тогда будет выглядеть вот так:

```
root@polygon:/home/user/DockerTest# docker images
REPOSITORY    TAG       IMAGE ID       CREATED         SIZE
weblistener   latest    56248aaa6ea0   3 minutes ago   871MB
python        3.5       3687eb5ea744   3 years ago     871MB
```

REPOSITORY нам понадобится чуть позже

#### docker images 

Данная команда выводит существующие образы в системе. 

```
root@polygon:/home/user/DockerTest# docker images
REPOSITORY    TAG       IMAGE ID       CREATED         SIZE
weblistener   latest    56248aaa6ea0   3 minutes ago   871MB
python        3.5       3687eb5ea744   3 years ago     871MB
```

Немного полезных команд:

1. `docker image rm NAME` удаляет контейнер и освобождает место
2. `docker image push` и `docker image pull` используется для загрузки и скачки готовых образов
3. `docker image tag weblistener weblistener:1.0` добавляет тег контейнеру
4. `docker image rm weblistener:1.0` удалит тег, но только если это не последний тег образа

#### docker rm

`docker rm weblistener` удаляет контейнер

Также `docker rm -f weblistener` останавливает контейнер, если он запущен, а потом удаляет его. Но делать так не надо, желательно сначала отдельно остановить контейнер

### Работа с контейнерами докера

#### docker ps

Пример работы с запущенным контейнером. Если контейнеры не запущены, то выведется только оглавление

```
CONTAINER ID   IMAGE         COMMAND                  CREATED         STATUS         PORTS                                   NAMES
ffbbd997b34a   weblistener   "python PyWebListene…"   8 seconds ago   Up 7 seconds   0.0.0.0:8800->80/tcp, :::8800->80/tcp   python_weblistener
```

#### docker run

`docker run` используется для **первого старта** контейнера, тут указываются все флаги, которые необходимо для работы контейнера. В нашем случае также необходимо использовать несколько флагов

1. `-d` он же detach, отвязывает контейнер от консоли. Без этого флага если мы закроем консоль, контейнер тоже остановится 
2. `-p NUM:NUM` он же указание мостов внешних портов контейнера и внутренних портов. Таким образом, если мы напишем -p 8800:80, то любые запросы по 8800 извне будут восприниматься программами внутри контейнера как 80
3. `--name NAME` указывает имя запущенного контейнера для удобства ориентирования
4. `-t TAG` указывает тег запущенного контейнера для ориентирования

Итоговая команда выглядит так:

```
root@polygon:/home/user/DockerTest# docker run -d -p 8800:80 --name python_weblistener -t weblistener
ffbbd997b34aaf7352cd8d8db4dc9bee6c290198c4b6790d469b816ed4bb39a2
```

#### docker start

Когда мы остановили контейнер, не перебилдили его, и требуется снова его запустить, то мы используем 

`docker start ID/TAG/NAME`

Например:

`docker start weblistener`

#### docker stop

Когда нам необходимо остановить работающий контейнер, мы используем docker stop по той же логике, что и docker start

Пример:

`docker stop weblistener`

## Непосредственно тест

Попробуем сами. Для начала подготовим дерево папок и файлы:

```
1  mkdir DockerTest
2  cd DockerTest
3  mkdir src
4  touch Dockerfile .gitignore src/PyWebListener.py
```

Заполняем все файлы или используем scp или winscp (.gitignore, Dockerfile, PyWebListener.py)

```
9   docker build . -t weblistener
10  docker images
11  docker run -d -p 8800:80 --name python_weblistener -t weblistener
12  docker ps
```

Проверяем работу сервера (в браузере localhost:8800)

Ради практики останавливаем контейнер и удаляем образ

```
13  docker stop python_weblistener
14  docker rm python_weblistener
15  docker image rm weblistener
```

## Загрузка образа на Docker Hub

Делается это в три шага:

```
1  docker login
2  docker tag локальный_образ:тег логин/dockerhub_образ:тег
3  docker push логин/dockerhub_образ:тег
```

Любые ошибки в процессе докер прекрасно подсвечивает самостоятельно