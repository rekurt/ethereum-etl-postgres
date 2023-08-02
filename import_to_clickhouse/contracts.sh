#!/bin/bash

# Get values from environment variables
chhost=$CHHOST
chpass=$CHPASS
bucket=$CONTRACTS_BUCKET
gcskey=$GCSKEY
gcssecret=$GCSSECRET

# Check if all variables are set
if [[ -z $bucket || -z $chhost || -z $chpass || -z $gcskey || -z $gcssecret ]]; then
    echo "Одна из переменных окружения не установлена. Убедитесь, что все переменные (CONTRACTS_BUCKET, CH_HOST, CH_PASSWORD, GCS_API_KEY, GCS_API_SECRET) установлены."
    exit 1
fi



# Получаем список всех gz файлов из указанной папки на GCS
FILES=$(gsutil ls gs://$bucket | grep ".gz$")

# Проходимся по каждому файлу и выполняем запрос в clickhouse-client
for file in $FILES; do
    echo "Обработка $file..."
    # Извлекаем имя файла из полного пути
    filename=$(basename $file)
    clickhouse-client --host $chhost --secure --password $chpass -q "
    INSERT INTO contracts
    SELECT
        toFixedString(address, 42) as address,
        bytecode as bytecode,
        IF(function_sighashes = '{}', [], splitByChar(',', function_sighashes)) as function_sighashes,
        IF(is_erc20='true', 1, 0) as is_erc20,
        IF(is_erc721='true', 1, 0) as is_erc721,
        toInt64(block_number) as block_number,
        '' as block_hash, 
        toDateTime(replaceRegexpOne(block_timestamp, ' UTC', '')) as block_timestamp
    FROM s3('https://storage.googleapis.com/$bucket/$filename',
            '$gcskey',
            '$gcssecret',
            'CSV', 'address String, bytecode String, function_sighashes String, is_erc20 String, is_erc721 String, block_number String, block_timestamp String')
    SETTINGS input_format_allow_errors_num=10, input_format_allow_errors_ratio=0.01, format_csv_delimiter = ',';"
done

echo "Все файлы обработаны."
