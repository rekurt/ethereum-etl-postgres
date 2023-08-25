create table transactions
(
    hash varchar(66),
    nonce bigint,
    transaction_index bigint,
    from_address varchar(42),
    to_address varchar(42),
    value numeric(38),
    gas bigint,
    gas_price bigint,
    input text,
    receipt_cumulative_gas_used bigint,
    receipt_gas_used bigint,
    receipt_contract_address varchar(42),
    receipt_root varchar(66),
    receipt_status bigint,
    block_timestamp timestamp,
    block_number bigint,
    block_hash varchar(66),
    max_fee_per_gas bigint,
    max_priority_fee_per_gas bigint,
    transaction_type bigint,
    receipt_effective_gas_price bigint,
    effective_gas_price bigint,
    l1_fee bigint,
    l1_gas_used bigint,
    l1_gas_price bigint,
    l1_fee_scalar decimal
);
