# FinancialInstrument

[![R-CMD-check](https://github.com/JustinMShea/FinancialInstrument/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/JustinMShea/FinancialInstrument/actions/workflows/R-CMD-check.yaml)

FinancialInstrument provides infrastructure for defining, storing, and managing financial instrument metadata in R. 
Rather than focusing on market prices or returns, the package models the instruments themselves; their identities, specifications, and relationships. 
These instrument definitions can then be shared across research, trading, portfolio management, and analytics workflows.

The package supports currencies, equities, funds, futures, options, spreads, synthetic instruments, and custom instrument classes while remaining independent of any particular market data provider.

### Design Philosophy

Most financial software begins with market data. FinancialInstrument begins with the instrument.

A stock is more than a price series. A futures contract is more than a ticker. Every financial instrument has identity, metadata, relationships, and contract specifications that exist independently of any particular data vendor.

For example:

A futures root defines the common contract specification (currency, multiplier, tick size, exchange, and related metadata).
Individual future series inherit those properties while adding contract-specific information such as expiration dates and identifiers.
Options, spreads, and synthetic instruments build upon the same hierarchical model rather than requiring separate frameworks.

This approach separates instrument metadata from market data, allowing a single instrument definition to be reused regardless of whether prices originate from Yahoo Finance, Bloomberg, Refinitiv, Interactive Brokers, Polygon, or another data source.

FinancialInstrument therefore acts as an instrument registry and metadata model that can support many different quantitative finance workflows.


## Status

The package is being prepared for resubmission to CRAN. Until it is available from CRAN again, install the development version from GitHub.

## Installation

Install the package from GitHub with `remotes`:

```r
install.packages("remotes")
remotes::install_github("JustinMShea/FinancialInstrument")
```

After the package returns to CRAN, the standard installation command will be:

```r
install.packages("FinancialInstrument")
```

## Quick start

Financial instruments are stored in the package-level `.instrument` environment. Define currencies before defining instruments denominated in those currencies.

```r
library(FinancialInstrument)

# Define currencies
currency(c("USD", "EUR", "JPY"))

# Define stocks
stock(
  c("AAPL", "MSFT"),
  currency = "USD",
  exchange = "NASDAQ"
)

# Retrieve an instrument definition
getInstrument("AAPL")

# List the instruments currently defined
ls_instruments()

# Display instrument metadata as a data frame
instrument.table()
```

Additional metadata can be supplied as named arguments:

```r
stock(
  "IBM",
  currency = "USD",
  exchange = "NYSE",
  description = "IBM common stock",
  identifiers = list(
    Bloomberg = "IBM US Equity",
    Yahoo = "IBM"
  )
)

getInstrument("IBM")
```

## Futures and options

A futures root specification can be defined with its contract multiplier and tick size:

```r
currency("USD")

future(
  "ES",
  currency = "USD",
  multiplier = 50,
  tick_size = 0.25,
  description = "E-mini S&P 500 futures"
)

future_series(
  root_id = "ES",
  suffix_id = "Z26",
  expires = "2026-12-18"
)
```

For equity options, define the underlying stock and the option root before defining individual contracts:

```r
stock("SPY", currency = "USD")

option(
  ".SPY",
  currency = "USD",
  multiplier = 100,
  tick_size = 0.01,
  underlying_id = "SPY"
)

option_series(
  root_id = "SPY",
  expires = "2027-01-15",
  callput = "call",
  strike = 600
)
```

Functions that retrieve data from external providers can be affected by provider availability, API changes, authentication requirements, or rate limits.

## Saving instrument definitions

Save the current instrument environment:

```r
saveInstruments("instruments.RData")
```

Load saved definitions into the current environment:

```r
loadInstruments("instruments.RData")
```

To replace the current instrument environment with the saved definitions:

```r
reloadInstruments("instruments.RData")
```

## Reporting problems

Please report reproducible bugs and documentation problems through the [GitHub issue tracker](https://github.com/JustinMShea/FinancialInstrument/issues). Include:

- the output of `sessionInfo()`;
- a minimal reproducible example;
- the complete warning or error message;
- the operating system and R version.

## License

FinancialInstrument is distributed under a GNU General Public License, see the Description file for details. 
The package is free software and comes with absolutely no warranty.
