
#!/bin/bash
set -e

cd "$(dirname "$0")/.."

PROJECT="hw3_$$"
export HOST_PORT=$((20000 + $$ % 20000))
URL="http://127.0.0.1:$HOST_PORT"

compose() {
    docker compose -p "$PROJECT" "$@"
}

trap 'compose down -v' EXIT

check_count() {
    result=$(curl -fsS "$URL/")
    count=$(echo "$result" | sed -E 's/.*"count": *([0-9]+).*/\1/')
    echo "count = $count, expected = $1"
    test "$count" = "$1"
}

check_status() {
    code=$(curl -s -o /dev/null -w '%{http_code}' -X "$1" "$URL$2")
    echo "$1 $2: $code"
    test "$code" = "$3"
}

wait_ready() {
    for i in {1..5}; do
        if curl -f "$URL/readyz" > /dev/null 2>&1; then
            return 0
        fi
        sleep 1
    done
    return 1
}

echo "=== Запуск ==="
compose up --build --wait > /dev/null 2>&1
check_count 0

echo "=== Увеличение счётчика ==="
for i in {1..3}; do
    check_status POST /increment 200
done
check_count 3

echo "=== Пересоздание app ==="
compose up -d --no-deps --force-recreate app
wait_ready
check_count 3

echo "=== Отключение Redis ==="
compose stop redis
check_status GET /healthz 200
check_status GET /readyz 503
check_status POST /increment 503

echo "=== Восстановление Redis ==="
compose start redis
wait_ready
check_count 3
check_status POST /increment 200
check_count 4

echo "=== Резервная копия ==="
compose stop app redis
mkdir -p "backups/$PROJECT"

compose run --rm \
    -v "$PWD/backups/$PROJECT:/backup" \
    --entrypoint sh redis \
    -c 'tar -czf /backup/redis.tar.gz -C /data .'

test -s "backups/$PROJECT/redis.tar.gz"

echo "PASS: все проверки пройдены"
