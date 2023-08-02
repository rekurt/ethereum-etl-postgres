#!/bin/bash

# Get values from environment variables
chhost=$CHHOST
chpass=$CHPASS
bucket=$LOGS_BUCKET
gcskey=$GCSKEY
gcssecret=$GCSSECRET

# Check if all variables are set
if [[ -z $bucket || -z $chhost || -z $chpass || -z $gcskey || -z $gcssecret ]]; then
    echo "Одна из переменных окружения не установлена. Убедитесь, что все переменные (LOGS_BUCKET, CH_HOST, CH_PASSWORD, GCS_API_KEY, GCS_API_SECRET) установлены."
    exit 1
fi



# Получаем список всех gz файлов из указанной папки на GCS
FILES=$(gsutil ls gs://$bucket| grep ".gz$")

# Проходимся по каждому файлу и выполняем запрос в clickhouse-client
for file in $FILES; do
    echo "Processing $file..."
    # Извлекаем имя файла из полного пути
    filename=$(basename $file)
    clickhouse-client --host $chhost --secure --password $chpass -q "
    INSERT INTO logs
    SELECT
        toInt64(log_index),
        toFixedString(transaction_hash, 66),
        toInt64(transaction_index),
        toFixedString(address, 42),
        data,
        toFixedString(topic0, 66),
        toFixedString(topic1, 66),
        toFixedString(topic2, 66),
        toFixedString(topic3, 66),
        toDateTime(replaceRegexpOne(block_timestamp, ' UTC', '')),
        toInt64(block_number),
        toFixedString(block_hash, 66)
    FROM s3('https://storage.googleapis.com/$bucket/$filename',
            $gcskey,
            $gcssecret,
       'CSV', 'log_index String, transaction_hash String, transaction_index String, address String, data String, topic0 String, topic1 String, topic2 String, topic3 String, block_timestamp String, block_number String, block_hash String')
SETTINGS input_format_allow_errors_num=10, input_format_allow_errors_ratio=0.01, format_csv_delimiter = ',';
"
done

echo "All files processed."