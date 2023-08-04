#!/bin/bash

Please, enter the following variables:
Введите ключ API от GCS:GOOG2ZFYDWUKPCJYQCUQZU7N
Введите секретный ключ от GCS3TW8LNSNMEed8qHnefw8BPjv2fAVeXq4zEofEWR3
Введите путь до GCS папки с экспортированными логами: ppool2/export_temp_dataset.flattened_logs_raw
Введите адрес хоста Clickhouse: p0f1q6ayju.us-central1.gcp.clickhouse.cloud
Введите пароль от Clickhouse:Sg3Lh1IIBmYc~




Введите путь до GCS папки с экспортированными транзакциями: ppool2/export_temp_dataset.flattened_transactions_raw
Введите адрес хоста Clickhouse: p0f1q6ayju.us-central1.gcp.clickhouse.cloud
Введите пароль от Clickhouse: Sg3Lh1IIBmYc~
Введите ключ API от GCS:            'GOOGGXXULRSMY7NR7KP2XKAM',
            
Введите секретный ключ от GCS:  'fzeSNaZkjRJNtKfrz+J73beP1wAOppSYES0tSMdx',








-- transactions
INSERT INTO transactions
SELECT
    toFixedString(hash, 66),
    toInt64(nonce),=
    toDateTime(toDateTime(replaceRegexpOne(block_timestamp, ' UTC', ''))),
FROM s3('https://storage.googleapis.com/ppool2/export_temp_dataset.flattened_transactions_raw/*.gz',
        'CSV', 'hash String, nonce String, block_timestamp String')
SETTINGS input_format_allow_errors_num=10, input_format_allow_errors_ratio=0.01, format_csv_delimiter = ',';


