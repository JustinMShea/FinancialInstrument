# Regression tests for saveInstruments(), loadInstruments(),
# and reloadInstruments().

original_names <- ls_instruments()

original_instruments <- if (length(original_names)) {
  unname(lapply(original_names, getInstrument))
} else {
  list()
}

f_rdata <- tempfile(
  "fi_test_instr_",
  fileext = ".RData"
)

f_r <- tempfile(
  "fi_test_instr_",
  fileext = ".R"
)

f_dir <- tempfile(
  "fi_test_dir_",
  fileext = ".RData"
)

f_reload <- tempfile(
  "fi_test_reload_",
  fileext = ".RData"
)

test_files <- c(
  f_rdata,
  f_r,
  f_dir,
  f_reload
)

on.exit(
  {
    unlink(test_files)

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

currency("USD")

stock(
  "SAVE_SPY",
  currency = "USD",
  multiplier = 1
)

stock(
  "SAVE_DIA",
  currency = "USD",
  multiplier = 1
)

expected_spy <- getInstrument("SAVE_SPY")
expected_dia <- getInstrument("SAVE_DIA")

# RData round trip
saveInstruments(f_rdata)

expect_true(
  file.exists(f_rdata)
)

rm_instruments(
  keep.currencies = FALSE
)

loadInstruments(f_rdata)

expect_equal(
  getInstrument("SAVE_SPY"),
  expected_spy
)

expect_equal(
  getInstrument("SAVE_DIA"),
  expected_dia
)

# Generated R-file round trip
saveInstruments(f_r)

expect_true(
  file.exists(f_r)
)

rm_instruments(
  keep.currencies = FALSE
)

expect_silent(
  loadInstruments(f_r)
)

expect_equal(
  getInstrument("SAVE_SPY"),
  expected_spy
)

expect_equal(
  getInstrument("SAVE_DIA"),
  expected_dia
)

# Separate filename and directory arguments
saveInstruments(
  basename(f_dir),
  dir = dirname(f_dir)
)

expect_true(
  file.exists(f_dir)
)

# reloadInstruments() should replace the registry
rm_instruments(
  keep.currencies = FALSE
)

currency("USD")

stock(
  c("SAVE_AA", "SAVE_BB"),
  currency = "USD"
)

saveInstruments(f_reload)

stock(
  "SAVE_CC",
  currency = "USD"
)

expect_true(
  is.instrument.name("SAVE_CC")
)

reloadInstruments(f_reload)

expect_false(
  is.instrument.name("SAVE_CC")
)

expect_true(
  is.instrument.name("SAVE_AA")
)

expect_true(
  is.instrument.name("SAVE_BB")
)
