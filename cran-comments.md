## Test environments

* Local Ubuntu 22.04, R 4.6.1
* Local Ubuntu 24.04, R 4.6.1
* GitHub Actions, Ubuntu, R release
* win-builder, R release
* win-builder, R-devel

## R CMD check results

0 errors | 0 warnings | 1 note

The remaining NOTE reports that FinancialInstrument was previously archived on CRAN. This is expected for this resubmission.

## Resubmission

This is a resubmission of FinancialInstrument 1.4.1 addressing the reviewer feedback received after the 1.4.0 submission.

The following changes were made:

* Added missing return-value documentation to exported functions and regenerated the package manuals.
* Corrected broken and incomplete examples.
* Removed commented-out executable alternatives from examples.
* Replaced unnecessary `\dontrun{}` sections with executable examples or `\donttest{}` where an external service is required.
* Updated examples that write files to use temporary directories and restore instrument-registry state.
* Removed direct `FinancialInstrument:::.instrument` access from documentation examples.
* Confirmed that `expires()` is exported.
* Restored and tested the previously exported `rm_by_currency()` function.
* Made progress output from `alltick2sec()` suppressible through a new trailing `verbose = FALSE` argument.
* Removed default writes to fixed locations in the user’s home directory while preserving calls that provide explicit paths.
* Added regression tests for instrument saving, loading, registry restoration, and currency-based removal.

There is no publication associated with the package infrastructure, so no DOI or ISBN applies.

Ross Bennett, the previous maintainer, agreed to the maintainer transition and provided confirmation directly to CRAN.
