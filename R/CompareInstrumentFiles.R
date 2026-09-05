#' Compare Instrument Files
#'
#' Compare the .instrument environments of two files
#'
#' This will load two instrument files (created by
#' \code{\link{saveInstruments}}) and find the differences between them.  In
#' addition to returning a list of difference that are found, it will produce
#' messages indicating the number of instruments that were added, the number of
#' instruments that were removed, and the number of instruments that are
#' different.
#'
#' @param file1 A file containing an instrument environment
#' @param file2 Another file containing an instrument environment.  If not
#'   provided, \code{file1} will be compared against the currently loaded
#'   instrument environment.
#' @param ... Arguments to pass to \code{\link{all.equal.instrument}}
#' @return A list that contains the names of all instruments that were added,
#'   the names of all instruments that were removed, and the changes to all
#'   instruments that were updated (per \code{\link{all.equal.instrument}}).
#' @author Garrett See
#' @seealso \code{\link{saveInstruments}}, \code{\link{all.equal.instrument}}
#' @examples
#' example_dir <- tempfile("fi-compare-")
#' dir.create(example_dir)
#'
#' backup_name <- "backup.RData"
#' file1_name <- "instruments1.RData"
#' file2_name <- "instruments2.RData"
#'
#' backup_path <- file.path(example_dir, backup_name)
#' file1_path <- file.path(example_dir, file1_name)
#' file2_path <- file.path(example_dir, file2_name)
#'
#' saveInstruments(backup_name, dir = example_dir)
#'
#' tryCatch(
#'   {
#'     stopifnot(file.exists(backup_path))
#'
#'     rm_instruments(keep.currencies = FALSE)
#'     currency("USD")
#'     stock(c("SPY", "DIA", "GLD"), currency = "USD")
#'     saveInstruments(file1_name, dir = example_dir)
#'
#'     stopifnot(file.exists(file1_path))
#'
#'     rm_stocks("GLD")
#'     stock("QQQ", currency = "USD")
#'     instrument_attr(
#'       "SPY",
#'       "description",
#'       "S&P 500 ETF"
#'     )
#'     saveInstruments(file2_name, dir = example_dir)
#'
#'     stopifnot(file.exists(file2_path))
#'
#'     CompareInstrumentFiles(file1_path, file2_path)
#'   },
#'   finally = {
#'     if (file.exists(backup_path)) {
#'       reloadInstruments(backup_name, dir = example_dir)
#'     }
#'
#'     unlink(example_dir, recursive = TRUE)
#'   }
#' )
#'
#' @export
CompareInstrumentFiles <- function(file1, file2, ...) {
    force(file1)
    #backup current instrument environment
    bak <- as.list(.instrument, all.names=TRUE)
    # load files to be compared
    reloadInstruments(file1)
    orig <- as.list(.instrument, all.names=TRUE)
    if (!missing(file2)) {
        force(file2)
        reloadInstruments(file2)
        new <- as.list(.instrument, all.names=TRUE)
    } else new <- bak
    #restore user's instrument environment
    reloadInstruments(bak)
    new.instruments <- names(new)[!names(new) %in% names(orig)]
    removed.instruments <- names(orig)[!names(orig) %in% names(new)]
    lni <- length(new.instruments)
    if (lni == 1L) { # grammar
        message(paste("1 instrument added."))
    } else {
        message(paste(lni, "instruments added."))
    }
    lri <- length(removed.instruments)
    if (lri == 1L) { #grammar
        message(paste("1 instrument removed."))
    } else {
        message(paste(lri, "instruments removed."))
    }
    # now look at changes of those that both have in common
    to.comp <- names(new)[names(new) %in% names(orig)]
    diffs <- lapply(to.comp, function(x) {
        ae <- all.equal(orig[[x]], new[[x]], ...)
        if (!isTRUE(ae)) ae
    }) #took about 11 seconds for me on fast computer with 7500 instruments
    names(diffs) <- to.comp
    diffs <- diffs[!vapply(diffs, is.null, logical(1))]
    liu <- length(diffs)
    if (liu == 1L) { #grammar
        message(paste("1 instrument updated."))
    } else {
        message(paste(liu, "instruments updated."))
    }
    out <- c(list(new.instruments=new.instruments,
                  removed.instruments=removed.instruments),
             diffs)
    out <- Filter(function(x) length(x) > 0L, out)
    if (length(out) > 0L) {
        out
    }
}


