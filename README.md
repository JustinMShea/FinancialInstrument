# FinancialInstrument

[![R-CMD-check](https://github.com/JustinMShea/FinancialInstrument/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/JustinMShea/FinancialInstrument/actions/workflows/R-CMD-check.yaml)
[![URL check](https://github.com/JustinMShea/FinancialInstrument/actions/workflows/url-check.yaml/badge.svg)](https://github.com/JustinMShea/FinancialInstrument/actions/workflows/url-check.yaml)

`FinancialInstrument` provides infrastructure for defining, storing, and retrieving metadata and relationships for tradable financial instruments in R. It supports currencies, stocks, funds, futures, options, spreads, synthetic instruments, and custom instrument classes.

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

## Development

To check the exact source package that would be submitted to CRAN:

```sh
R CMD build .
R CMD check --as-cran FinancialInstrument_*.tar.gz
```

## Continuous integration

The repository includes GitHub Actions workflows that:

- run `R CMD check` on Linux, macOS, and Windows;
- test R release, R-devel, and the previous R release;
- run on pushes and pull requests;
- run weekly to identify breakage caused by changing dependencies;
- build the source package and check its URLs.

Workflow files are stored in `.github/workflows/`.

## Reporting problems

Please report reproducible bugs and documentation problems through the [GitHub issue tracker](https://github.com/JustinMShea/FinancialInstrument/issues). Include:

- the output of `sessionInfo()`;
- a minimal reproducible example;
- the complete warning or error message;
- the operating system and R version.

## License

FinancialInstrument is distributed under the GNU General Public License.
