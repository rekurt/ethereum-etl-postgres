#!/bin/bash

# Get values from environment variables
chhost=$CHHOST
chpass=$CHPASS
bucket=$TXS_BUCKET
start=$TXS_START
gcskey=$GCSKEY
gcssecret=$GCSSECRET

# Check if all variables are set
if [[ -z $bucket || -z $chhost || -z $chpass || -z $gcskey || -z $gcssecret ]]; then
    echo "Одна из переменных окружения не установлена. Убедитесь, что все переменные (TXS_BUCKET, CH_HOST, CH_PASSWORD, GCS_API_KEY, GCS_API_SECRET) установлены."
    exit 1
fi


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
    INSERT INTO transactions
    SELECT
        toFixedString(hash, 66),
        toInt64(nonce),
        toInt64(transaction_index),
        toFixedString(from_address, 42),
        toFixedString(to_address, 42),
        toDecimal128(value, 0),
        toInt64(gas),
        toInt64(gas_price),
        input,
        toInt64(receipt_cumulative_gas_used),
        toInt64(receipt_gas_used),
        toFixedString(receipt_contract_address, 42),
        toFixedString(receipt_root, 66),
        ifNull(toInt64(nullIf(receipt_status, '')), 0),
        toDateTime(toDateTime(replaceRegexpOne(block_timestamp, ' UTC', ''))),
        toInt64(block_number),
        toFixedString(block_hash, 66),
        ifNull(toInt64(nullIf(max_fee_per_gas, '')), 0),
        ifNull(toInt64(nullIf(max_priority_fee_per_gas, '')), 0),
        ifNull(toInt64(nullIf(transaction_type, '')), 0),
        ifNull(toInt64(nullIf(receipt_effective_gas_price, '')), 0)
    FROM s3('https://storage.googleapis.com/$bucket/$filename',
            '$gcskey',
            '$gcssecret',
            'CSV', 'hash String, nonce String, transaction_index String, from_address String, to_address String, value String, gas String, gas_price String, input String, receipt_cumulative_gas_used String, receipt_gas_used String, receipt_contract_address String, receipt_root String, receipt_status String, block_timestamp String, block_number String, block_hash String, max_fee_per_gas String, max_priority_fee_per_gas String, transaction_type String, receipt_effective_gas_price String')
    SETTINGS input_format_allow_errors_num=10, input_format_allow_errors_ratio=0.01, format_csv_delimiter = ',';"
    fi

done

echo "Все файлы обработаны."
