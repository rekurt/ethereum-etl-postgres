#!/bin/bash

echo "This script will import blocks from GCS to Clickhouse"
echo "You need to have gsutil installed and configured to work with your GCS bucket"
echo "You need to have clickhouse-client installed and configured to work with your Clickhouse instance"
echo "Please, enter the following variables:"

# Prompt the user to enter 5 variables
read -p "Введите адрес хоста Clickhouse:" chhost
read -p "Введите пароль от Clickhouse:" chpass
read -p "Введите путь до GCS папки с экспортированными блоками: " blocks
read -p "Введите путь до GCS папки с экспортированными транзакциями: " txs
read -p "Введите путь до GCS папки с экспортированными логами: " logs
read -p "Введите путь до GCS папки с экспортированными контрактами: " contracts
read -p "Введите путь до GCS папки с экспортированными traces: " traces
read -p "Введите путь до GCS папки с экспортированными tokens: " tokens
read -p "Введите путь до GCS папки с экспортированными token transfers: " token_transfers
read -p "Введите ключ API от GCS:" gcskey
read -p "Введите секретный ключ от GCS" gcssecret


export CHHOST=$chhost
export CHPASS=$chpass
export BLOCKS_BUCKET=$blocks
export TXS_BUCKET=$txs
export LOGS_BUCKET=$logs
export CONTRACTS_BUCKET=$contracts
export TT_BUCKET=$token_transfers
export TRACES_BUCKET=$traces
export TOKENS_BUCKET=$tokens
export GCSKEY=$gcskey
export GCSSECRET=$gcssecret

./init.sh

nohup ./blocks.sh > blocks.log 2>&1 &
nohup ./tx.sh > tx.log 2>&1 &
nohup ./logs.sh > logs.log 2>&1 &
nohup ./contracts.sh > contracts.log 2>&1 &
nohup ./tokens.sh > tokens.log 2>&1 &
nohup ./traces.sh > traces.log 2>&1 &
nohup ./token_transfers.sh > token_transfers.log 2>&1 &
