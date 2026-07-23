###############################################################################
# R (http://r-project.org/) Instrument Class Model
#
# Copyright (c) 2009-2012
# Peter Carl, Dirk Eddelbuettel, Jeffrey Ryan,
# Joshua Ulrich, Brian G. Peterson, and Garrett See
#
# This library is distributed under the terms of the GNU Public License (GPL)
# for full details see the file COPYING
#
# $Id$
#
###############################################################################

#' List instruments by currency denomination
#'
#' Returns the names of instruments denominated in one or more specified
#' currencies.
#'
#' @param currency Character vector containing the names of currencies.
#' @param pattern An optional regular expression. Only instrument names
#'   matching `pattern` are returned.
#' @param match Logical. Should `pattern` be matched exactly?
#' @param show.currencies Logical. Should currency instruments themselves be
#'   included in the returned names?
#' @param x Character vector of instrument names to remove. If missing, all
#'   instruments denominated in `currency` are selected.
#' @param keep.currencies Logical. If `TRUE`, retain the currency instruments
#'   themselves.
#'
#' @return A character vector containing instrument names denominated in the
#'   requested currencies, or `NULL` when no matching instruments are found.
#'
#' @author Garrett See
#'
#' @seealso
#' [ls_instruments()], [ls_currencies()], [rm_instruments()],
#' [rm_currencies()], [instrument()]
#'
#' @examples
#' example_dir <- tempfile("fi-currency-")
#' dir.create(example_dir)
#'
#' backup_name <- "backup.RData"
#' backup_path <- file.path(example_dir, backup_name)
#'
#' saveInstruments(backup_name, dir = example_dir)
#'
#' tryCatch(
#'   {
#'     rm_instruments(keep.currencies = FALSE)
#'
#'     currency(c("USD", "CAD", "GBP"))
#'     stock(c("CM", "CNQ"), currency = "CAD")
#'     stock(c("BARC", "BET"), currency = "GBP")
#'     stock(c("DIA", "SPY"), currency = "USD")
#'
#'     ls_by_currency("CAD")
#'     ls_by_currency("GBP")
#'     ls_USD()
#'     ls_CAD()
#'
#'     rm_by_currency(currency = "CAD")
#'
#'   },
#'   finally = {
#'     if (file.exists(backup_path)) {
#'       reloadInstruments(
#'         backup_name,
#'         dir = example_dir
#'       )
#'     }
#'
#'     unlink(example_dir, recursive = TRUE)
#'   }
#' )
#'
#' @export
#' @rdname ls_by_currency
ls_by_currency <- function(
    currency,
    pattern = NULL,
    match = TRUE,
    show.currencies = FALSE
) {
  if (length(pattern) > 1L && !match) {
    warning("Using match because length of pattern > 1.")
    match <- TRUE
  }

  undefined_currencies <- currency[
    !currency %in% ls_currencies()
  ]

  if (length(undefined_currencies)) {
    warning(
      paste(undefined_currencies, collapse = ", "),
      if (length(undefined_currencies) == 1L) {
        " is not a defined currency"
      } else {
        " are not defined currencies"
      },
      call. = FALSE
    )
  }

  if (!is.null(pattern) && match) {
    symbols <- ls_instruments()
    symbols <- symbols[match(pattern, symbols)]
  } else if (!match && length(pattern) == 1L) {
    symbols <- ls_instruments(pattern = pattern)
  } else if (is.null(pattern)) {
    symbols <- ls_instruments()
  }

  tmp_symbols <- NULL

  for (symbol in symbols) {
    tmp_instr <- try(
      get(symbol, pos = .instrument),
      silent = TRUE
    )

    if (
      is.instrument(tmp_instr) &&
      !is.null(tmp_instr$currency) &&
      any(tmp_instr$currency %in% currency)
    ) {
      tmp_symbols <- c(tmp_symbols, symbol)
    }
  }

  if (show.currencies) {
    tmp_symbols
  } else if (!is.null(tmp_symbols)) {
    ls_non_currencies(tmp_symbols)
  } else {
    NULL
  }
}
#' @export
#' @rdname ls_by_currency
rm_by_currency <- function(
    x,
    currency,
    keep.currencies = TRUE
) {
  show_currencies <- !keep.currencies

  if (missing(x)) {
    x <- ls_by_currency(
      currency = currency,
      show.currencies = show_currencies
    )
  } else {
    x <- ls_by_currency(
      currency = currency,
      pattern = x,
      show.currencies = show_currencies
    )
  }

  rm(list = x, pos = .instrument)
}
#AUD GBP CAD EUR JPY CHF HKD SEK NZD
#' @export
#' @rdname ls_by_currency
ls_USD <- function(pattern=NULL,match=TRUE,show.currencies=FALSE) {
    ls_by_currency('USD',pattern,match,show.currencies)
}
#' @export
#' @rdname ls_by_currency
ls_AUD <- function(pattern=NULL,match=TRUE,show.currencies=FALSE) {
    ls_by_currency('AUD',pattern,match,show.currencies)
}
#' @export
#' @rdname ls_by_currency
ls_GBP <- function(pattern=NULL,match=TRUE,show.currencies=FALSE) {
    ls_by_currency('GBP',pattern,match,show.currencies)
}
#' @export
#' @rdname ls_by_currency
ls_CAD <- function(pattern=NULL,match=TRUE,show.currencies=FALSE) {
    ls_by_currency('CAD',pattern,match,show.currencies)
}
#' @export
#' @rdname ls_by_currency
ls_EUR <- function(pattern=NULL,match=TRUE,show.currencies=FALSE) {
    ls_by_currency('EUR',pattern,match,show.currencies)
}
#' @export
#' @rdname ls_by_currency
ls_JPY <- function(pattern=NULL,match=TRUE,show.currencies=FALSE) {
    ls_by_currency('JPY',pattern,match,show.currencies)
}
#' @export
#' @rdname ls_by_currency
ls_CHF <- function(pattern=NULL,match=TRUE,show.currencies=FALSE) {
    ls_by_currency('CHF',pattern,match,show.currencies)
}
#' @export
#' @rdname ls_by_currency
ls_HKD <- function(pattern=NULL,match=TRUE,show.currencies=FALSE) {
    ls_by_currency('HKD',pattern,match,show.currencies)
}
#' @export
#' @rdname ls_by_currency
ls_SEK <- function(pattern=NULL,match=TRUE,show.currencies=FALSE) {
    ls_by_currency('SEK',pattern,match,show.currencies)
}
#' @export
#' @rdname ls_by_currency
ls_NZD <- function(pattern=NULL,match=TRUE,show.currencies=FALSE) {
    ls_by_currency('NZD',pattern,match,show.currencies)
}
