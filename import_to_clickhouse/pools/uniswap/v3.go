package uniswap

import "time"

type Pool struct {
	Address              string `json:"id"`
	Base                 Token  `json:"token0"`
	Quoted               Token  `json:"token1"`
	Tick                 string `json:"tick"`
	FeeTier              string `json:"feeTier"`
	CreatedAtTimestamp   string `json:"createdAtTimestamp"`
	CreatedAtBlockNumber string `json:"createdAtBlockNumber"`
}

type Token struct {
	Address  string `json:"id"`
	Symbol   string `json:"symbol"`
	Decimals string `json:"decimals"`
}

// PoolHistoricalData contains historical data for a pool
type PoolHistoricalData struct {
	ID          string
	Timestamp   time.Time
	VolumeUSD   float64
	Reserve0    float64
	Reserve1    float64
	TotalSupply float64
	TxCount     int
	Token0Price float64
	Token1Price float64
}

// TokenHistoricalData contains historical data for a token
type TokenHistoricalData struct {
	ID          string
	Timestamp   time.Time
	PriceUSD    float64
	TotalSupply float64
	TradeVolume float64
	TxCount     int
}

// Transaction contains data for a transaction
type Transaction struct {
	ID          string
	BlockNumber int
	Timestamp   time.Time
	From        string
	To          string
	Value       float64
	GasUsed     float64
	GasPrice    float64
}

// Swap contains data for a swap
type Swap struct {
	ID         string
	Timestamp  time.Time
	Sender     string
	Amount0In  float64
	Amount1In  float64
	Amount0Out float64
	Amount1Out float64
	To         string
	Pool       Pool
}

// Mint contains data for a mint
type Mint struct {
	ID        string
	Timestamp time.Time
	Minter    string
	Amount0   float64
	Amount1   float64
	To        string
	Pool      Pool
}

// Burn contains data for a burn
type Burn struct {
	ID        string
	Timestamp time.Time
	Burner    string
	Amount0   float64
	Amount1   float64
	To        string
	Pool      Pool
}
type UniswapV3Service interface {
	// Fetches pool by ID
	GetPoolByID(id string) (Pool, error)

	// Fetches all pools
	GetAllPools() ([]Pool, error)

	// Fetches top N pools by volume
	GetTopPoolsByVolume(n int) ([]Pool, error)

	// Fetches pools by token
	GetPoolsByToken(tokenID string) ([]Pool, error)

	// Fetches token by ID
	GetTokenByID(id string) (Token, error)

	// Fetches all tokens
	GetAllTokens() ([]Token, error)

	// Fetches top N tokens by volume
	GetTopTokensByVolume(n int) ([]Token, error)

	// Fetches historical data for a pool
	GetPoolHistoricalData(id string) (PoolHistoricalData, error)

	// Fetches historical data for a token
	GetTokenHistoricalData(id string) (TokenHistoricalData, error)

	// Fetches pools by volume range
	GetPoolsByVolumeRange(minVolume float64, maxVolume float64) ([]Pool, error)

	// Fetches tokens by volume range
	GetTokensByVolumeRange(minVolume float64, maxVolume float64) ([]Token, error)

	// Fetches pools with a specific token pair
	GetPoolsByTokenPair(token0ID string, token1ID string) ([]Pool, error)

	// Fetches the latest transactions for a pool
	GetPoolTransactions(id string) ([]Transaction, error)

	// Fetches the latest transactions for a token
	GetTokenTransactions(id string) ([]Transaction, error)

	// Fetches the latest swaps for a pool
	GetPoolSwaps(id string) ([]Swap, error)

	// Fetches the latest swaps for a token
	GetTokenSwaps(id string) ([]Swap, error)

	// Fetches the latest mints for a pool
	GetPoolMints(id string) ([]Mint, error)

	// Fetches the latest mints for a token
	GetTokenMints(id string) ([]Mint, error)

	// Fetches the latest burns for a pool
	GetPoolBurns(id string) ([]Burn, error)

	// Fetches the latest burns for a token
	GetTokenBurns(id string) ([]Burn, error)
}
