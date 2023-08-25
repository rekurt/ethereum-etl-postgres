#!/bin/bash

Please, enter the following variables:
Введите ключ API от GCS:GOOG2ZFYDWUKPCJYQCUQZU7N
Введите секретный ключ от GCS3TW8LNSNMEed8qHnefw8BPjv2fAVeXq4zEofEWR3
Введите путь до GCS папки с экспортированными логами: ppool2/export_temp_dataset.flattened_logs_raw
Введите адрес хоста Clickhouse: p0f1q6ayju.us-central1.gcp.clickhouse.cloud
Введите пароль от Clickhouse:Sg3Lh1IIBmYc~



export CHHOST=p0f1q6ayju.us-central1.gcp.clickhouse.cloud
export CHPASS="~PWS8Lr5yUAg2"
export BLOCKS_BUCKET=ppool-gap/bigquery-public-data:crypto_ethereum.blocks
export TXS_BUCKET=ppool-gap/export_temp_dataset.flattened_transactions
export LOGS_BUCKET=ppool-gap/bigquery-public-data:crypto_ethereum.logs
export CONTRACTS_BUCKET=ppool-gap/bigquery-public-data:crypto_ethereum.contracts
export TT_BUCKET=ppool-gap/bigquery-public-data:crypto_ethereum.token_transfers
export TRACES_BUCKET=ppool/bigquery-public-data:crypto_ethereum.traces
export GCSKEY="GOOGZQS7IHRFCGOG7KI2RKM2"
export GCSSECRET="RVRh/8ulx09pdzPhHujXDfsTYCEaPzu/tJpcVrIb"