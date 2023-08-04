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

# Получаем список всех gz файлов из указанной папки на GCS
FILES=$(gsutil ls gs://$bucket | grep ".gz$")

# Проходимся по каждому файлу и выполняем запрос в clickhouse-client
for file in $FILES; do
    echo "Обработка $file..."
    # Извлекаем имя файла из полного пути
    filename=$(basename $file)
    
    clickhouse-client --host $chhost --secure --password $chpass -q "
    INSERT INTO tokens (address, name, symbol, decimals, total_supply, block_timestamp, block_number, block_hash)
    SELECT
        toFixedString(address, 42),
        name,
        symbol,
        toInt32OrNull(decimals),
        toInt64OrNull(total_supply), 
        toDateTime(toDateTime(replaceRegexpOne(block_timestamp, ' UTC', ''))),
        toInt64(block_number),
        toFixedString(block_hash, 66)
    FROM s3('https://storage.googleapis.com/$bucket/$filename',
            '$gcskey',
            '$gcssecret',
        'CSV', 'address String, name String, symbol String, decimals String, total_supply String, block_timestamp String, block_number String, block_hash String')
    SETTINGS input_format_allow_errors_num=10, input_format_allow_errors_ratio=0.01, format_csv_delimiter = ',';"
done

echo "Все файлы обработаны."
