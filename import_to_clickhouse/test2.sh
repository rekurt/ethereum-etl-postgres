#!/bin/bash

echo "Этот скрипт импортирует данные токенов из GCS в Clickhouse."
echo "Для работы необходимо установить gsutil и настроить его для работы с вашим GCS bucket."
echo "Для работы необходимо установить clickhouse-client и настроить его для работы с вашим экземпляром Clickhouse."
echo ""
echo "Пожалуйста, введите следующие переменные:"

# Запрашиваем у пользователя 5 переменных
read -p "Введите путь до GCS папки с экспортированными данными токенов (без имени файла и расширения, пример: 'ppool2/bigquery-public-data:crypto_ethereum.tokens_raw/'): " bucket
read -p "Введите адрес хоста Clickhouse: " chhost
read -p "Введите пароль от Clickhouse: " chpass
read -p "Введите ключ API от GCS: " gcskey
read -p "Введите секретный ключ от GCS: " gcssecret
read -p "Введите секретный ключ от GCS: " gcssecret

# Check if all variables are set
if [[ -z $bucket || -z $chhost || -z $chpass || -z $gcskey || -z $gcssecret ]]; then
    echo "Одна из переменных окружения не установлена. Убедитесь, что все переменные (TXS_BUCKET, CH_HOST, CH_PASSWORD, GCS_API_KEY, GCS_API_SECRET) установлены."
    exit 1
fi

# Получаем список всех gz файлов из указанной папки на GCS
FILES=$(gsutil ls gs://$bucket | grep ".gz$")
STOP="gs://ppool2/export_temp_dataset.flattened_transactions_raw/000000009186.gz"
# Проходимся по каждому файлу и выполняем запрос в clickhouse-client
for file in $FILES; do

    # Сравниваем имя файла с заданными значениями
    if [[ "$file" > $STOP ]]; then
        echo "Обработка $file..."
    fi
done

echo "Все файлы обработаны."

a:crypto_ethereum.tokens_raw/'): ppool2/export_temp_dataset.flattened_transactions_raw
Введите адрес хоста Clickhouse: p0f1q6ayju.us-central1.gcp.clickhouse.cloud
Введите пароль от Clickhouse: Sg3Lh1IIBmYc~
Введите ключ API от GCS: GOOGGXXULRSMY7NR7KP2XKAM
Введите секретный ключ от GCS: fzeSNaZkjRJNtKfrz+J73beP1wAOppSYES0tSMdx