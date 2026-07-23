# Regression tests for saveInstruments / loadInstruments / reloadInstruments
# Covers: explicit output paths, RData and R/txt formats, state restore.

test_dir <- tempfile("fi-test-save-")
dir.create(test_dir)

# ---- helpers ---------------------------------------------------------------
cleanup <- function() {
    unlink(test_dir, recursive = TRUE)
    rm_instruments(keep.currencies = FALSE)
}
on.exit(cleanup(), add = TRUE)

# ---- setup: define some instruments ----------------------------------------
rm_instruments(keep.currencies = FALSE)
currency("USD")
stock("SAVE_SPY", currency = "USD")
stock("SAVE_DIA", currency = "USD")

# ---- saveInstruments writes an RData file to explicit dir ------------------
saveInstruments("test.RData", dir = test_dir)
expect_true(file.exists(file.path(test_dir, "test.RData")))

# ---- loadInstruments restores instruments from explicit path ---------------
rm_instruments(keep.currencies = FALSE)
expect_false(is.instrument.name("SAVE_SPY"))

loadInstruments("test.RData", dir = test_dir)
expect_true(is.instrument.name("SAVE_SPY"))
expect_true(is.instrument.name("SAVE_DIA"))

# ---- saveInstruments writes an .R (text) file to explicit dir --------------
currency("USD")
stock("SAVE_SPY", currency = "USD")
saveInstruments("test.R", dir = test_dir)
expect_true(file.exists(file.path(test_dir, "test.R")))

# ---- loadInstruments reads the .R file from explicit path ------------------
rm_instruments(keep.currencies = FALSE)
expect_false(is.instrument.name("SAVE_SPY"))

loadInstruments("test.R", dir = test_dir)
expect_true(is.instrument.name("SAVE_SPY"))

# ---- reloadInstruments replaces the registry --------------------------------
currency("USD")
stock(c("SAVE_AA", "SAVE_BB"), currency = "USD")
saveInstruments("reload.RData", dir = test_dir)

stock("SAVE_CC", currency = "USD")   # add extra instrument
expect_true(is.instrument.name("SAVE_CC"))

reloadInstruments("reload.RData", dir = test_dir)
expect_false(is.instrument.name("SAVE_CC"))  # extra should be gone
expect_true(is.instrument.name("SAVE_AA"))

# ---- file_name with full path (no dir argument) ----------------------------
full_path <- tempfile(tmpdir = test_dir, fileext = ".RData")
currency("USD")
stock("SAVE_SPY", currency = "USD")
saveInstruments(full_path)
expect_true(file.exists(full_path))

rm_instruments(keep.currencies = FALSE)
loadInstruments(full_path)
expect_true(is.instrument.name("SAVE_SPY"))
