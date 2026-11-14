## Проверка задания на 4 балла

### Сборка образа

```bash
docker docker build -t hw .
```

### Запуск контейнера

```bash
docker run -d --name cont  \  
  -p 127.0.0.1:8080:8000 \
  -e GREETING='Hello from a container!' \
  hw
```

### Проверка работы

Выполнены запросы:

```bash
curl -fsS http://localhost:8080/
curl -fsS -X POST http://localhost:8080/increment
curl -fsS http://localhost:8080/readyz
```

Результаты: приложение отвечает на запросы, значение счётчика увеличивается, проверка готовности возвращает успешный ответ.

Логи работы контейнера сохранены в `log1.txt`.


6 баллов
Выполнены  запросы:

```bash 
curl -fsS -X POST http://localhost:8080/increment
curl -fsS -X POST http://localhost:8080/increment
curl -fsS http://localhost:8080/
docker compose down
docker compose up -d
curl -fsS http://localhost:8080/
```

Результаты: приложение отвечает на запросы, значение счётчика увеличивается, при остановке и удалении контейнера и перезапуске приложения значение счёетчика не меняется.

Текст симуляции теста есть, сохранёен в `check.txt`.

8 баллов : 

Выполнены запросы :

```bash
curl -fsS -X POST http://localhost:8080/increment
curl -fsS -X POST http://localhost:8080/increment
curl -fsS http://localhost:8080/

docker compose down
docker compose up -d --wait

curl -fsS http://localhost:8080/

docker compose stop redis

curl -sS -o /dev/null -w '%{http_code}\n' http://localhost:8080/healthz
curl -sS -o /dev/null -w '%{http_code}\n' http://localhost:8080/readyz
curl -sS -o /dev/null -w '%{http_code}\n' -X POST http://localhost:8080/increment

docker compose start redis

curl -fsS http://localhost:8080/
curl -fsS -X POST http://localhost:8080/increment
```

В целос тоже самое с результатами команд есть в `redis_check.txt`. Все тесты прощли успешно.

10 баллов : 

Ну скрипт есть , проверки в файлах `check_10_1.txt` и `check_10_2.txt`

