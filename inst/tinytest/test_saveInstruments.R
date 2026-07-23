# Regression tests for saveInstruments / loadInstruments / reloadInstruments
# Covers: full-path save/load, RData and R/txt formats, dir argument, state restore.
#
# All test files are written directly into tempdir() (which always exists during
# R CMD check) to avoid issues with creating subdirectories in constrained envs.

td <- tempdir()
f_rdata  <- file.path(td, "fi_test_instr.RData")
f_r      <- file.path(td, "fi_test_instr.R")
f_reload <- file.path(td, "fi_test_reload.RData")

# ---- helpers ---------------------------------------------------------------
on.exit({
    unlink(c(f_rdata, f_r, f_reload))
    rm_instruments(keep.currencies = FALSE)
}, add = TRUE)

# ---- setup: define some instruments ----------------------------------------
rm_instruments(keep.currencies = FALSE)
currency("USD")
stock("SAVE_SPY", currency = "USD")
stock("SAVE_DIA", currency = "USD")

# ---- saveInstruments: full path, .RData ------------------------------------
saveInstruments(f_rdata)
expect_true(file.exists(f_rdata))

# ---- loadInstruments: full path, .RData ------------------------------------
rm_instruments(keep.currencies = FALSE)
expect_false(is.instrument.name("SAVE_SPY"))

loadInstruments(f_rdata)
expect_true(is.instrument.name("SAVE_SPY"))
expect_true(is.instrument.name("SAVE_DIA"))

# ---- saveInstruments: full path, .R (text) ---------------------------------
currency("USD")
stock("SAVE_SPY", currency = "USD")
saveInstruments(f_r)
expect_true(file.exists(f_r))

# ---- loadInstruments: full path, .R ----------------------------------------
rm_instruments(keep.currencies = FALSE)
expect_false(is.instrument.name("SAVE_SPY"))

loadInstruments(f_r)
expect_true(is.instrument.name("SAVE_SPY"))

# ---- saveInstruments with dir argument --------------------------------------
currency("USD")
stock("SAVE_SPY", currency = "USD")
stock("SAVE_DIA", currency = "USD")
saveInstruments("fi_test_dir.RData", dir = td)
expect_true(file.exists(file.path(td, "fi_test_dir.RData")))
unlink(file.path(td, "fi_test_dir.RData"))

# ---- reloadInstruments replaces the registry --------------------------------
currency("USD")
stock(c("SAVE_AA", "SAVE_BB"), currency = "USD")
saveInstruments(f_reload)

stock("SAVE_CC", currency = "USD")
expect_true(is.instrument.name("SAVE_CC"))

reloadInstruments(f_reload)
expect_false(is.instrument.name("SAVE_CC"))  # extra should be gone
expect_true(is.instrument.name("SAVE_AA"))
