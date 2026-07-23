original_names <- ls_instruments()

original_instruments <- if (length(original_names)) {
  unname(lapply(original_names, getInstrument))
} else {
  list()
}

on.exit(
  {
    rm_instruments(
      keep.currencies = FALSE
    )

    if (length(original_instruments)) {
      loadInstruments(original_instruments)
    }
  },
  add = TRUE
)

rm_instruments(
  keep.currencies = FALSE
)

currency(
  c("USD", "CAD")
)

stock(
  "USD_STOCK",
  currency = "USD"
)

stock(
  "CAD_STOCK",
  currency = "CAD"
)

expect_true(
  "rm_by_currency" %in%
    getNamespaceExports("FinancialInstrument")
)

rm_by_currency(
  currency = "CAD"
)

expect_true(
  is.instrument.name("USD_STOCK")
)

expect_false(
  is.instrument.name("CAD_STOCK")
)

# Currency definition should remain by default.
expect_true(
  is.instrument.name("CAD")
)

stock(
  "CAD_STOCK",
  currency = "CAD"
)

rm_by_currency(
  currency = "CAD",
  keep.currencies = FALSE
)

expect_false(
  is.instrument.name("CAD_STOCK")
)

expect_false(
  is.instrument.name("CAD")
)
