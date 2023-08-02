#!/bin/bash


# Get values from environment variables
chhost=$CHHOST
chpass=$CHPASS
bucket=$BLOCKS_BUCKET
gcskey=$GCSKEY
gcssecret=$GCSSECRET

# Check if all variables are set
if [[ -z $bucket || -z $chhost || -z $chpass || -z $gcskey || -z $gcssecret ]]; then
    echo "Одна из переменных окружения не установлена. Убедитесь, что все переменные (BLOCKS_BUCKET, CH_HOST, CH_PASSWORD, GCS_API_KEY, GCS_API_SECRET) установлены."
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
    INSERT INTO blocks
    SELECT
        toDateTime(replaceRegexpOne(timestamp, ' UTC', '')),
        toInt64(number)
    FROM s3('https://storage.googleapis.com/$bucket/$filename',
            $gcskey,
            $gcssecret,
            'CSV', 'timestamp String, number String')
    SETTINGS input_format_allow_errors_num=10, input_format_allow_errors_ratio=0.1, format_csv_delimiter = ',';"
done

echo "All files processed."