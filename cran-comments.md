## Test environments

* Local Ubuntu Linux (22.04 and 24.04), R 4.6.1 (2026-06-24)
* win-builder (R release and R-devel)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Submission Notes

This is a resubmission of the previously archived package **FinancialInstrument**. The issues that led to archival have been addressed.

Ross Bennett, the previous CRAN maintainer, has agreed to the maintainer transition and has sent confirmation directly to CRAN.

The following changes were made for this release:

* Justin M. Shea is now the package maintainer, and the `DESCRIPTION` file has been updated accordingly.
* Updated legacy roxygen2 documentation blocks across multiple source files (`instrument.R`, `ls_by_currency.R`, `ls_instruments.R`, and `FinancialInstrument-package.R`) to comply with current roxygen2 parsing requirements, including `@aliases` and `@importFrom` directives.
* Corrected S3 generic/method registration for `expires.spread`.
* Added the appropriate package-qualified Rd cross-reference for `quantmod::setSymbolLookup`.
* Added `Encoding: UTF-8` to the package metadata.
* Removed hyperlinks to Yahoo Finance from the documentation because Yahoo returns HTTP 429 responses during automated URL checks.

Additional improvements made during the update include:

* Migrated the testing framework from `testthat` to `tinytest`.
* Expanded test coverage for frequency-mixed `xts` time-series alignment.
* Added a `README.md` and GitHub Actions continuous integration workflows for automated package checks.
