package main

import (
	"context"
	"encoding/csv"
	"fmt"
	"log"
	"os"

	"github.com/machinebox/graphql"

	"pools/uniswap"
)

type ResponseData struct {
	Pools []uniswap.Pool `json:"pools"`
}

const POOLS_PER_PAGE = 1000
const UNISWAP_V3_SUBGRAPH = "https://api.thegraph.com/subgraphs/name/uniswap/uniswap-v3"
const POOLS_FILE = "pools.csv"
const TOKENS_FILE = "tokens.csv"

func main() {
	ctx := context.Background()
	client := graphql.NewClient(UNISWAP_V3_SUBGRAPH)

	poolChan := make(chan uniswap.Pool)
	doneChan := make(chan bool)
	go savePoolsToCSV(poolChan, doneChan, POOLS_FILE)

	var lastPoolID string
	var totalPools int

	fields := `{
			id
			tick
			feeTier
			createdAtTimestamp
			createdAtBlockNumber	
			token0 {
				id
				symbol
				decimals
			}
			token1 {
				id
				symbol
				decimals
			}
		}`
	for {

		var req *graphql.Request
		if lastPoolID == "" {
			req = graphql.NewRequest(fmt.Sprintf(`
				{
					pools(first: %d, orderBy: createdAtTimestamp, orderDirection: asc) %s
				}
			`, POOLS_PER_PAGE, fields))
		} else {
			req = graphql.NewRequest(fmt.Sprintf(`
				{
					pools(first: %d, orderBy: createdAtTimestamp, orderDirection: asc
					where: {createdAtTimestamp_gt: %s }) %s

				}
			`, POOLS_PER_PAGE, lastPoolID, fields))
		}

		var responseData ResponseData

		if err := client.Run(ctx, req, &responseData); err != nil {
			log.Fatal(err)
		}
		for _, pool := range responseData.Pools {
			poolChan <- pool
			lastPoolID = pool.CreatedAtTimestamp
			totalPools++
		}
		log.Println("Processed", totalPools, "pools")
		if len(responseData.Pools) < POOLS_PER_PAGE {
			break
		}
	}

	close(poolChan)
	<-doneChan
}

func savePoolsToCSV(poolChan <-chan uniswap.Pool, doneChan chan<- bool, fileName string) {
	file, err := os.Create(fileName)
	if err != nil {
		log.Fatal("Failed to create file")
	}
	defer file.Close()
	writer := csv.NewWriter(file)
	defer writer.Flush()

	if err := writer.Write([]string{"Address", "BaseAddress", "BaseSymbol", "BaseDecimals", "QuotedAddress", "QuotedSymbol", "QuotedDecimals", "Tick", "Fee Tier"}); err != nil {
		log.Fatal(err)
	}
	for pool := range poolChan {
		if err := writer.Write([]string{pool.Address, pool.Base.Address, pool.Base.Symbol, fmt.Sprint(pool.Base.Decimals), pool.Quoted.Address, pool.Quoted.Symbol, fmt.Sprint(pool.Quoted.Decimals), fmt.Sprint(pool.Tick), fmt.Sprint(pool.FeeTier)}); err != nil {
			log.Fatal(err)
		}
	}
	doneChan <- true
}
