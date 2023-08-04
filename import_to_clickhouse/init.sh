#!/bin/bash
# Get values from environment variables
chhost=$CHHOST
chpass=$CHPASS

# Check if all variables are set
if [[ -z $chhost || -z $chpass ]]; then
    echo "Одна из переменных окружения не установлена. Убедитесь, что все переменные (CHHOST, CHPASS) установлены."
    exit 1
fi 

echo "Creating table blocks"
 clickhouse-client --host $chhost --secure --password $chpass -q "
  CREATE TABLE blocks
(
    timestamp DateTime CODEC(ZSTD(1)),
    number Int64 CODEC(ZSTD(1)),
    hash FixedString(66),
    parent_hash FixedString(66),
    nonce FixedString(42),
    sha3_uncles FixedString(66),
    logs_bloom String,
    transactions_root FixedString(66),
    state_root FixedString(66),
    receipts_root FixedString(66),
    miner FixedString(42),
    difficulty Decimal(38, 0) CODEC(ZSTD(1)),
    total_difficulty Decimal(38, 0) CODEC(ZSTD(1)),
    size Int64 CODEC(ZSTD(1)),
    extra_data String,
    gas_limit Int64 CODEC(ZSTD(1)),
    gas_used Int64 CODEC(ZSTD(1)),
    transaction_count Int64 CODEC(ZSTD(1)),
    base_fee_per_gas Int64 CODEC(ZSTD(1)),
    withdrawals String,
    withdrawals_root String(),
) ENGINE = MergeTree() PARTITION BY 
toYYYYMM(timestamp) ORDER BY timestamp SETTINGS index_granularity = 8192;

"
echo "Creating table contracts"
 clickhouse-client --host $chhost --secure --password $chpass -q "
  
CREATE TABLE contracts
(
    address FixedString(42),
    bytecode String,
    function_sighashes Array(String),
    is_erc20 UInt8,
    is_erc721 UInt8,
    block_number Int64 CODEC(ZSTD(1)),
    block_hash FixedString(66),
    block_timestamp DateTime CODEC(ZSTD(1))
) ENGINE = MergeTree() PARTITION BY 
toYYYYMM(block_timestamp) ORDER BY block_timestamp SETTINGS index_granularity = 8192;

"
echo "Creating table logs"
 clickhouse-client --host $chhost --secure --password $chpass -q "
  
CREATE TABLE logs
(
    log_index Int64 CODEC(ZSTD(1)),
    transaction_hash FixedString(66),
    transaction_index Int64 CODEC(ZSTD(1)),
    address FixedString(42),
    data String,
    topic0 FixedString(66),
    topic1 FixedString(66),
    topic2 FixedString(66),
    topic3 FixedString(66),
    block_timestamp DateTime CODEC(ZSTD(1)),
    block_number Int64 CODEC(ZSTD(1)),
    block_hash FixedString(66)
) ENGINE = MergeTree() PARTITION BY 
toYYYYMM(block_timestamp) ORDER BY block_timestamp SETTINGS index_granularity = 8192;

"
echo "Creating table token_transfers"
 clickhouse-client --host $chhost --secure --password $chpass -q "
  
CREATE TABLE token_transfers
(
    token_address FixedString(42),
    from_address FixedString(42),
    to_address FixedString(42),
    value Int64 CODEC(ZSTD(1)),
    transaction_hash FixedString(66),
    log_index Int64 CODEC(ZSTD(1)),
    block_timestamp DateTime CODEC(ZSTD(1)),
    block_number Int64 CODEC(ZSTD(1)),
    block_hash FixedString(66)
) ENGINE = MergeTree() PARTITION BY 
toYYYYMM(block_timestamp) ORDER BY block_timestamp SETTINGS index_granularity = 8192;

"
echo "Creating table transactions"
 clickhouse-client --host $chhost --secure --password $chpass -q "
  
CREATE TABLE transactions
(
    hash FixedString(66),
    nonce Int64 CODEC(ZSTD(1)),
    transaction_index Int64 CODEC(ZSTD(1)),
    from_address FixedString(42),
    to_address FixedString(42),
    value Decimal(38, 0) CODEC(ZSTD(1)),
    gas Int64 CODEC(ZSTD(1)),
    gas_price Int64 CODEC(ZSTD(1)),
    input String,
    receipt_cumulative_gas_used Int64 CODEC(ZSTD(1)),
    receipt_gas_used Int64 CODEC(ZSTD(1)),
    receipt_contract_address FixedString(42),
    receipt_root FixedString(66),
    receipt_status Int64 CODEC(ZSTD(1)),
    block_timestamp DateTime CODEC(ZSTD(1)),
    block_number Int64 CODEC(ZSTD(1)),
    block_hash FixedString(66),
    max_fee_per_gas Int64 CODEC(ZSTD(1)),
    max_priority_fee_per_gas Int64 CODEC(ZSTD(1)),
    transaction_type Int64 CODEC(ZSTD(1)),
    receipt_effective_gas_price Int64 CODEC(ZSTD(1))
) ENGINE = MergeTree() PARTITION BY 
toYYYYMM(block_timestamp) ORDER BY block_timestamp SETTINGS index_granularity = 8192;

"


echo "Creating table tokens"
clickhouse-client --host $chhost --secure --password $chpass -q "

CREATE TABLE tokens
(
    address FixedString(42),
    name String,
    symbol String,
    decimals Int32 CODEC(ZSTD(1)),
    total_supply Decimal(76, 0) CODEC(ZSTD(1)),
    block_number Int64 CODEC(ZSTD(1)),
    block_hash FixedString(66),
    block_timestamp DateTime CODEC(ZSTD(1))
) ENGINE = MergeTree() PARTITION BY 
toYYYYMM(block_timestamp) ORDER BY block_timestamp SETTINGS index_granularity = 8192;
"

echo "Creating table traces"
clickhouse-client --host $chhost --secure --password $chpass -q "
CREATE TABLE traces
(
    transaction_hash FixedString(66),
    transaction_index Int64 CODEC(ZSTD(1)),
    from_address FixedString(42),
    to_address FixedString(42),
    value Decimal(38, 0) CODEC(ZSTD(1)),
    input String,
    output String,
    trace_type FixedString(16),
    call_type FixedString(16),
    reward_type FixedString(16),
    gas Int64 CODEC(ZSTD(1)),
    gas_used Int64 CODEC(ZSTD(1)),
    subtraces Int64 CODEC(ZSTD(1)),
    trace_address FixedString(8192),
    error String,
    status Int32 CODEC(ZSTD(1)),
    block_timestamp DateTime CODEC(ZSTD(1)),
    block_number Int64 CODEC(ZSTD(1)),
    block_hash FixedString(66),
    trace_id String
) ENGINE = MergeTree() PARTITION BY 
toYYYYMM(block_timestamp) ORDER BY block_timestamp SETTINGS index_granularity = 8192;
" 