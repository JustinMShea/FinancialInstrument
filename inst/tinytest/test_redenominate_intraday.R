# 1. Setup
options(xts_check_TZ = FALSE)
.dat_mix <- new.env()
currency(c("USD", "CCY"))
exchange_rate("USDCCY")
stock("xus_intra", "USD")

# 2. Intraday asset data (UTC)
idx_intra <- as.POSIXct(c("2010-01-01 09:30:00", "2010-01-01 14:00:00", "2010-01-04 10:30:00"), tz = "UTC")
xus_intra <- xts(c(10, 12, 15), idx_intra)

# 3. Daily FX data (UTC)
# Set the FX start date to be clearly before the intraday data to ensure it's picked up
idx_daily <- as.POSIXct(c("2010-01-01 00:00:00", "2010-01-02 00:00:00", "2010-01-04 00:00:00"), tz = "UTC")
USDCCY <- xts(c(2.0, 2.1, 3.0), idx_daily)

# 4. Align FX rate to asset index
# Use fromLast = TRUE to backfill the first observation
merged_data <- merge(xus_intra, USDCCY, all = TRUE)
merged_data$USDCCY <- na.locf(merged_data$USDCCY, na.rm = FALSE)
merged_data$USDCCY <- na.locf(merged_data$USDCCY, fromLast = TRUE) # Backfill the start

# Subset back to only the intraday timestamps
aligned_rate <- merged_data[index(xus_intra), "USDCCY"]

# 5. Assign
assign("xus_intra", xus_intra, envir = .dat_mix)
assign("USDCCY", aligned_rate, envir = .dat_mix)

# 6. Execute
res_intra <- redenominate("xus_intra", "CCY", "USD", env = .dat_mix)

# 7. Verify
expect_equal(NROW(res_intra), 3)

# Check values using the correct column index (1)
expect_equal(as.numeric(res_intra[, 1]), c(20, 24, 45))
