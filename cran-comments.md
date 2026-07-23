## Test environments

* Local Ubuntu Linux (22.04 and 24.04), R 4.6.1 (2026-06-24)
* win-builder (R release and R-devel)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Submission Notes

This is a resubmission of version 1.4.1, addressing the CRAN reviewer feedback
received after the 1.4.0 submission.

### Changes addressing CRAN reviewer feedback

* **Return-value documentation:** Added `\value` sections to all exported
  functions that were previously missing them, describing the return class,
  structure, and side-effects.

* **Examples — file paths:** All examples that previously wrote to the current
  working directory now use `tempdir()` / `tempfile()` and clean up with
  `tryCatch(finally = ...)`.

* **Examples — `FinancialInstrument:::.instrument`:** Removed all `:::` access
  to the internal registry from documentation examples. Backup/restore patterns
  now use the exported `saveInstruments()` / `reloadInstruments()` API.

* **Examples — unmatched parenthesis:** Fixed the unmatched parenthesis in the
  `ls_by_currency()` example.

* **Examples — commented-out executable code:** Removed commented-out
  executable alternatives from all examples.

* **`\dontrun{}` vs `\donttest{}`:** Converted examples that can be run in a
  standard R session from `\dontrun{}` to either runnable or `\donttest{}`
  blocks. `\dontrun{}` is now reserved for genuinely unrunnable code.

* **Console output (`alltick2sec`):** Added `verbose = FALSE` at the end of
  the `alltick2sec()` signature. The previously unconditional `cat()` progress
  message is now suppressed by default and uses `message()` when enabled,
  preserving all existing return values.

### There is no associated publication; no DOI or ISBN applies.

