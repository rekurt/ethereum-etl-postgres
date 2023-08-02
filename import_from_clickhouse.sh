#!/bin/bash

# Получаем список всех gz файлов из указанной папки на GCS
FILES=$(gsutil ls gs://ppool2/export_temp_dataset.flattened_blocks_raw | grep ".gz$")

# Проходимся по каждому файлу и выполняем запрос в clickhouse-client
for file in $FILES; do
    echo "Processing $file..."
    # Извлекаем имя файла из полного пути
    filename=$(basename $file)
    clickhouse-client -q "
    SET parallel_distributed_insert_select = 1;
    INSERT INTO blocks
    SELECT
        toDateTime(replaceRegexpOne(timestamp, ' UTC', '')),
        toInt64(number),
        toFixedString(hash, 66),
        toFixedString(parent_hash, 66),
        toFixedString(nonce, 42),
        toFixedString(sha3_uncles, 66),
        logs_bloom,
        toFixedString(transactions_root, 66),
        toFixedString(state_root, 66),
        toFixedString(receipts_root, 66),
        toFixedString(miner, 42),
        toFixedString(difficulty, 42),
        toFixedString(total_difficulty, 42),
        toInt64(size),
        extra_data,
        toInt64(gas_limit),
        toInt64(gas_used),
        toInt64(transaction_count),
        toFixedString(base_fee_per_gas, 38),
        toString(withdrawals_root),
        toString(withdrawals)
    FROM s3('https://storage.googleapis.com/ppool2/export_temp_dataset.flattened_blocks_raw/$filename',
            'GOOG2ZFYDWUKPCJYQCUQZU7N',
            '3TW8LNSNMEed8qHnefw8BPjv2fAVeXq4zEofEWR3',
            'CSV', 'timestamp String, number String, hash String, parent_hash String, nonce String, sha3_uncles String, logs_bloom String, transactions_root String, state_root String, receipts_root String, miner String, difficulty String, total_difficulty String, size String, extra_data String, gas_limit String, gas_used String, transaction_count String, base_fee_per_gas String, withdrawals_root String, withdrawals String')
    SETTINGS input_format_allow_errors_num=10, input_format_allow_errors_ratio=0.1, format_csv_delimiter = ',';"
done

echo "All files processed."
