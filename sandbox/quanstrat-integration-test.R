library(FinancialInstrument)
library(blotter)
library(quantstrat)
library(xts)

suppressWarnings(
  rm(list = ls(envir = FinancialInstrument:::.instrument),
     envir = FinancialInstrument:::.instrument)
)

currency("USD")

stock(
  "TEST",
  currency = "USD",
  multiplier = 1
)

dates <- as.Date("2020-01-01") + 0:9

TEST <- xts(
  cbind(
    Open = 100:109,
    High = 101:110,
    Low = 99:108,
    Close = 100:109,
    Volume = rep(1000, 10),
    Adjusted = 100:109
  ),
  order.by = dates
)

portfolio_name <- "fi_compat_portfolio"
account_name <- "fi_compat_account"

initPortf(
  portfolio_name,
  symbols = "TEST",
  initDate = "2019-12-31"
)

initAcct(
  account_name,
  portfolios = portfolio_name,
  initDate = "2019-12-31",
  initEq = 100000
)

initOrders(
  portfolio = portfolio_name,
  initDate = "2019-12-31"
)

addTxn(
  Portfolio = portfolio_name,
  Symbol = "TEST",
  TxnDate = as.character(dates[2]),
  TxnQty = 10,
  TxnPrice = 101
)

updatePortf(portfolio_name)
updateAcct(account_name)
updateEndEq(account_name)

stopifnot(
  getInstrument("TEST")$multiplier == 1,
  getPosQty(
    portfolio_name,
    "TEST",
    as.character(dates[3])
  ) == 10
)

