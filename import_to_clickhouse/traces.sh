#!/bin/bash

echo "Этот скрипт импортирует данные трейсов из GCS в Clickhouse."
echo "Для работы необходимо установить gsutil и настроить его для работы с вашим GCS bucket."
echo "Для работы необходимо установить clickhouse-client и настроить его для работы с вашим экземпляром Clickhouse."
echo ""
echo "Пожалуйста, введите следующие переменные:"

# Запрашиваем у пользователя 5 переменных
read -p "Введите путь до GCS папки с экспортированными данными трейсов (без имени файла и расширения, пример: 'ppool2/bigquery-public-data:crypto_ethereum.traces_raw/'): " bucket
read -p "Введите адрес хоста Clickhouse: " chhost
read -p "Введите пароль от Clickhouse: " chpass
read -p "Введите ключ API от GCS: " gcskey
read -p "Введите секретный ключ от GCS: " gcssecret
read -p "Введите номер партиции для старта : " start

# Получаем список всех gz файлов из указанной папки на GCS
FILES=$(gsutil ls gs://$bucket | grep ".gz$")
START="gs://$bucket/$start.gz"

# Проходимся по каждому файлу и выполняем запрос в clickhouse-client
for file in $FILES; do
    echo "Обработка $file..."
    # Извлекаем имя файла из полного пути
    filename=$(basename $file)
    if [[ "$file" > $START ]]; then
    
    clickhouse-client --host $chhost --secure --password $chpass -q "
    INSERT INTO traces
    SELECT
        toFixedString(transaction_hash, 66) AS transaction_hash,
        toInt64OrNull(transaction_index) AS transaction_index,
        toFixedString(from_address, 42) AS from_address,
        toFixedString(to_address, 42) AS to_address,
        toInt64(value) AS value,
        input,
        output,
        toFixedString(trace_type, 16) AS trace_type,
        toFixedString(call_type, 16) AS call_type,
        toFixedString(reward_type, 16) AS reward_type,
        toInt64OrNull(gas) AS gas,
        toInt64OrNull(gas_used) AS gas_used,
        toInt64(subtraces) AS subtraces,
        toFixedString(trace_address, 8192) AS trace_address,
        error,
        toInt32(status) AS status,
        toDateTime(replaceRegexpOne(block_timestamp, ' UTC', '')) AS block_timestamp,
        toInt64(block_number) AS block_number,
        toFixedString(block_hash, 66) AS block_hash,
        trace_id
    FROM s3('https://storage.googleapis.com/$bucket/$filename',
            '$gcskey',
            '$gcssecret',
        'CSV', 'transaction_hash String, transaction_index String, from_address String, to_address String, value String, input String, output String, trace_type String, call_type String, reward_type String, gas String, gas_used String, subtraces String, trace_address String, error String, status String, block_timestamp String, block_number String, block_hash String, trace_id String')
    SETTINGS input_format_allow_errors_num=10, input_format_allow_errors_ratio=0.01, format_csv_delimiter = ',';"
    fi
done

echo "Все файлы обработаны."
