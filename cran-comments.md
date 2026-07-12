## Test environments
* Local Ubuntu Linux setup (22.04, 24.04), R version 4.6.1 (2026-06-24)
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 0 notes

* This is a release updating package maintainership and resolving legacy documentation syntax.

## Submission Notes

This is a resubmission of package FinancialInstrument, which was previously archived. The issues regarding NOTES that have been resolved.

* Justin M. Shea is taking over as the Maintainer of the package from Ross Bennett.
* Fixed warnings relating to legacy roxygen2 documentation blocks across multiple source files (`instrument.R`, `ls_by_currency.R`, `ls_instruments.R`, and `FinancialInstrument-package.R`) to resolve multi-line parsing constraints (`@aliases` and `@importFrom`).
* Resolved S3 generic/method registration alignment for `expires.spread`.
* Fixed missing package anchors for `setSymbolLookup` to properly target `quantmod`.
* Declared `Encoding: UTF-8` within the DESCRIPTION file metadata to comply with CRAN submission baselines.

The following enhancements were made in the process

* Migrated the unit testing framework from `testthat` to `tinytest`.
* Enhanced test coverage for frequency-mixed `xts` time-series alignment.
* Cleaned up internal documentation by refactoring helper functions and suppressing Rd generation for non-exported utilities.
