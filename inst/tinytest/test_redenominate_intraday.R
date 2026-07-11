
# redenominate mix intraday and daily data #

.dat_mix <- new.env()

currency(c("USD", "CCY"))
exchange_rate("USDCCY")
stock("xus_intra", "USD")

with(.dat_mix, {
  # Intraday asset data (POSIXct)
  idx_intra <- as.POSIXct(c("2010-01-01 09:30:00", "2010-01-01 14:00:00", "2010-01-04 10:30:00"), tz = "UTC")
  xus_intra <- xts(c(10, 12, 15), idx_intra)

  # Daily FX data (Date)
  idx_daily <- as.Date(c("2010-01-01", "2010-01-02", "2010-01-04"))
  USDCCY <- xts(c(2.0, 2.1, 3.0), idx_daily)
})

# Convert intraday USD asset to CCY using daily FX rates.
# Logic:
# 2010-01-01 09:30:00 -> 10 * 2.0 = 20
# 2010-01-01 14:00:00 -> 12 * 2.0 = 24
# 2010-01-04 10:30:00 -> 15 * 3.0 = 45
res_intra <- redenominate("xus_intra", "CCY", "USD", env=.dat_mix)

# Verify the object structure remains intact
expect_inherits(res_intra, "xts")

# Verify the engine didn't strip the POSIXct timezone or truncate to Date
expect_identical(index(res_intra), index(.dat_mix$xus_intra))

# Verify the math aligned the daily rates to the intraday observations correctly
expect_equal(as.numeric(res_intra), c(20, 24, 45))
