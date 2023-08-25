#!/bin/bash

# Get values from environment variables
chhost=$CHHOST
chpass=$CHPASS
bucket=$TT_BUCKET
gcskey=$GCSKEY
gcssecret=$GCSSECRET

# Получаем список всех gz файлов из указанной папки на GCS
FILES=$(gsutil ls gs://$bucket | grep ".gz$")

# Проходимся по каждому файлу и выполняем запрос в clickhouse-client
for file in $FILES; do
    echo "Обработка $file..."
    # Извлекаем имя файла из полного пути
    filename=$(basename $file)
    
    clickhouse-client --host $chhost --secure --password $chpass -q "
    INSERT INTO token_transfers (token_address, from_address, to_address, value, transaction_hash, log_index, block_timestamp, block_number, block_hash)
    SELECT
        toFixedString(token_address, 42),
        toFixedString(from_address, 42),
        toFixedString(to_address, 42),
        toInt64(value),
        toFixedString(transaction_hash, 66),
        toInt64(log_index),
        toDateTime(toDateTime(replaceRegexpOne(block_timestamp, ' UTC', ''))),
        toInt64(block_number),
        toFixedString(block_hash, 66)
    FROM s3('https://storage.googleapis.com/$bucket/$filename',
            '$gcskey',
            '$gcssecret',
        'CSV', 'token_address String, from_address String, to_address String, value String, transaction_hash String, log_index String, block_timestamp String, block_number String, block_hash String')
    SETTINGS input_format_allow_errors_num=10, input_format_allow_errors_ratio=0.01, format_csv_delimiter = ',';"
done

echo "Все файлы обработаны."
