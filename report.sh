#!/usr/bin/env bash
# Использование: ./report.sh <каталог> <ERROR|WARN> [--top N]

usage() {
    echo "Использование: $0 <каталог> <ERROR|WARN> [--top N]" >&2
}

# 1. Минимум два аргумента
if [ $# -lt 2 ]; then
    usage
    exit 1
fi

dir=$1
level=$2
shift 2

# 2. Проверка уровня
case "$level" in
    ERROR|WARN) ;;
    *) echo "Неверный уровень: $level" >&2; usage; exit 1 ;;
esac

# 3. Проверка каталога
if [ ! -d "$dir" ]; then
    echo "Каталог не существует: $dir" >&2
    usage
    exit 1
fi

# 4. Необязательный --top N
top=""
if [ $# -gt 0 ]; then
    if [ "$1" = "--top" ] && [ $# -eq 2 ] && [[ "$2" =~ ^[1-9][0-9]*$ ]]; then
        top=$2
    else
        echo "Неверные аргументы: --top требует число N" >&2
        usage
        exit 1
    fi
fi

# 5. Подсчёт: поле 3 — уровень, поле 4 — модуль
result=$(find "$dir" -type f -name '*.log' -print0 \
    | xargs -0 -r cat \
    | awk -v lvl="$level" '$3 == lvl { c[$4]++ } END { for (m in c) print c[m], m }' \
    | sort -k1,1nr -k2,2)

if [ -n "$top" ]; then
    result=$(echo "$result" | head -n "$top")
fi

echo "МОДУЛЬ  ЧИСЛО"
echo "$result" | awk 'NF { printf "%-10s %s\n", $2, $1 }'
