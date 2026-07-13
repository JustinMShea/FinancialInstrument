# future_series

# Use a clean instrument registry so these tests are independent of other
# tinytest files.
rm_instruments(keep.currencies = FALSE)
currency("USD")

suppressWarnings(
  future(
    "ES",
    currency = "USD",
    multiplier = 50,
    tick_size = 0.25,
    underlying_id = NULL,
    exchange = "CME",
    description = "E-mini S&P 500 futures"
  )
)

# A complete identifier is parsed into a futures series that inherits the root
# contract specification.
es_z26 <- future_series("ES_Z26", assign_i = FALSE)

expect_inherits(es_z26, "future_series")
expect_inherits(es_z26, "future")
expect_inherits(es_z26, "instrument")
expect_identical(es_z26$primary_id, "ES_Z26")
expect_identical(es_z26$root_id, "ES")
expect_identical(es_z26$suffix_id, "Z26")
expect_identical(es_z26$currency, "USD")
expect_identical(es_z26$multiplier, 50)
expect_identical(es_z26$tick_size, 0.25)
expect_identical(es_z26$exchange, "CME")
expect_identical(es_z26$expires, "2026-12")
expect_false(is.instrument.name("ES_Z26"))

# root_id and suffix_id may be supplied separately.
expect_identical(
  future_series(root_id = "ES", suffix_id = "H27"),
  "ES_H27"
)
expect_inherits(getInstrument("ES_H27"), "future_series")

# A suffix may be derived from a full expiration date.
expect_identical(
  future_series(root_id = "ES", expires = "2027-06-18"),
  "ES_M27"
)
expect_identical(getInstrument("ES_M27")$expires, "2027-06-18")

# Month-only expiration values remain supported.
expect_silent(
  es_u27 <- future_series(
    root_id = "ES",
    suffix_id = "U27",
    expires = "2027-09",
    assign_i = FALSE
  )
)
expect_identical(es_u27$expires, "2027-09")

# A parseable mismatch warns while preserving legacy construction behavior.
expect_warning(
  es_bad_month <- future_series(
    root_id = "ES",
    suffix_id = "H27",
    expires = "2027-12-17",
    assign_i = FALSE
  ),
  "indicates March 2027"
)
expect_inherits(es_bad_month, "future_series")
expect_identical(es_bad_month$expires, "2027-12-17")

# Invalid dates and unrecognized suffixes fail with useful messages.
expect_error(
  future_series(
    root_id = "ES",
    suffix_id = "H27",
    expires = "not-a-date",
    assign_i = FALSE
  ),
  "cannot be converted to Date"
)

expect_error(
  future_series(
    root_id = "ES",
    suffix_id = "BAD",
    assign_i = FALSE
  ),
  "not a recognized futures suffix"
)

# The first trading date cannot follow expiration.
expect_error(
  future_series(
    root_id = "ES",
    suffix_id = "H27",
    first_traded = "2027-04-01",
    expires = "2027-03-19",
    assign_i = FALSE
  ),
  "must not be after"
)

# Multiple complete identifiers retain the existing vectorized behavior.
series_ids <- future_series(c("ES_U28", "ES_Z28"))
expect_identical(series_ids, c("ES_U28", "ES_Z28"))
expect_true(all(is.instrument.name(series_ids)))

# Clean up package-level state for the remaining tinytest files.
rm_instruments(keep.currencies = FALSE)
