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

#' Convert tick data to one-second data
#'
#' This is like taking a snapshot of the market at the end of every second,
#' except the volume over the second is summed.
#'
#' From tick data with columns: \dQuote{Price}, \dQuote{Volume},
#' \dQuote{Bid.Price}, \dQuote{Bid.Size}, \dQuote{Ask.Price}, \dQuote{Ask.Size},
#' to data of one second frequency with columns \dQuote{Bid.Price},
#' \dQuote{Bid.Size}, \dQuote{Ask.Price}, \dQuote{Ask.Size},
#' \dQuote{Trade.Price}, and \dQuote{Volume}
#'
#' The primary purpose of these functions is to reduce the amount of data on
#' disk so that it will take less time to load the data into memory.
#'
#' If there are no trades or bid/ask price updates in a given second, we will
#' not make a row for that timestamp.  If there were no trades, but the bid or
#' ask price changed, then we _will_ have a row but the Volume and Trade.Price
#' will be NA.
#'
#' If there are multiple trades in the same second, Volume will be the sum of
#' the volume, but only the last trade price in that second will be printed.
#' Similarly, if there is a trade, and then later in the same second, there is
#' a bid/ask update, the last Bid/Ask Price/Size will be used.
#'
#' \code{alltick2sec} is used to convert the data of several files from tick to
#' one second frequency data.
#'
#' @param x the xts series to convert to 1 minute BATV
#'
#' @param getdir Directory containing tick data. If omitted, the value of
#'   \code{getOption("FinancialInstrument.tickdir")} is used.
#' @param savedir Directory in which converted data will be saved. If omitted,
#'   the value of \code{getOption("FinancialInstrument.secdir")} is used.
#' @param Symbols Character vector naming instruments to convert. If
#'   \code{NULL}, all entries in \code{getdir} are considered.
#' @param overwrite Logical. If a destination file already exists, should it
#'   be overwritten?
#' @param verbose Logical. If \code{TRUE}, display progress messages.
#' @return \code{to_secBATV} returns an xts object of one second frequency.
#'   \code{alltick2sec} returns a list of files that were converted.
#' @author gsee
#' @note \code{to_secBATV} is used by the TRTH_BackFill.R script in the
#'   inst/parser directory of the FinancialInstrument package.  These functions
#'   are specific to to data created by that script and are not intended for
#'   more general use.
#' @examples
#' \dontrun{
#' getSymbols("CLU1")
#' system.time(xsec <- to_secBATV(CLU1))
#' convert.log <- alltick2sec(
#'   getdir = "path/to/tick-data",
#'   savedir = "path/to/second-data",
#'   verbose = TRUE
#' )
#' }
#' @export
#' @rdname Tick2Sec
to_secBATV <- function(x) {
    #require(qmao)
    # Define Bi and As functions (copied from qmao package)
    Bi <- function(x) {
        if (has.Bid(x))
            return(x[, grep("Bid", colnames(x), ignore.case = TRUE)])
        stop("subscript out of bounds: no column name containing \"Bid\"")
    }
    As <- function(x) {
        if (has.Ask(x))
            return(x[, grep("Ask", colnames(x), ignore.case = TRUE)])
        stop("subscript out of bounds: no column name containing \"Ask\"")
    }
    ohlcv <- suppressWarnings(to.period(x[, 1:2], 'seconds', 1))
    ba <- x[, -c(1:2)]
    Volm <- if (!has.Vo(ohlcv)) {
        rep(NA, NROW(ohlcv))
    } else Vo(ohlcv)
    ClVo <- if(length(ohlcv) != 0) { ohlcv[, 4:5] } else {
        tmp <- xts(cbind(rep(NA, NROW(x)), rep(NA, NROW(x))), index(x))
        tmp[endpoints(tmp, 'seconds')]
    }

    ClVo <- align.time(ClVo, 1)

    ba.sec <- align.time(to.period(ba, 'seconds', 1, OHLC=FALSE), 1)
    ba.sec <- na.locf(ba.sec)

    xx <- cbind(ba.sec, ClVo, all=TRUE)
    colnames(xx) <- c("Bid.Price", "Bid.Size", "Ask.Price", "Ask.Size", "Trade.Price", "Volume")

    xx
}


#' @rdname Tick2Sec
alltick2sec <- function(
    getdir = getOption(
      "FinancialInstrument.tickdir",
      NULL
    ),
    savedir = getOption(
      "FinancialInstrument.secdir",
      NULL
    ),
    Symbols = NULL,
    overwrite = FALSE,
    verbose = FALSE
) {
  if (
    is.null(getdir) ||
    length(getdir) != 1L ||
    is.na(getdir) ||
    !nzchar(getdir)
  ) {
    stop(
      paste0(
        "Supply 'getdir' or set ",
        "options(FinancialInstrument.tickdir = ...)."
      ),
      call. = FALSE
    )
  }

  if (
    is.null(savedir) ||
    length(savedir) != 1L ||
    is.na(savedir) ||
    !nzchar(savedir)
  ) {
    stop(
      paste0(
        "Supply 'savedir' or set ",
        "options(FinancialInstrument.secdir = ...)."
      ),
      call. = FALSE
    )
  }

  if (!dir.exists(getdir)) {
    stop(
      "'getdir' does not exist: ",
      getdir,
      call. = FALSE
    )
  }

  if (!dir.exists(savedir)) {
    stop(
      "'savedir' does not exist: ",
      savedir,
      call. = FALSE
    )
  }

  if (!requireNamespace("foreach", quietly = TRUE)) {
    stop(
      "Package ",
      dQuote("foreach"),
      " cannot be loaded.",
      call. = FALSE
    )
  }

  if (is.null(Symbols)) {
    Symbols <- list.files(getdir)
  }

  Symbols <- Symbols[
    !Symbols %in% "instruments.rda"
  ]

    gsep <- if(substr(getdir, nchar(getdir), nchar(getdir)) == "/") { "" } else "/"
    ssep <- if(substr(savedir, nchar(savedir), nchar(savedir)) == "/") {""} else "/"

    s <- NULL

    `%fi_foreach%` <- if (foreach::getDoParRegistered()) {
      foreach::`%dopar%`
    } else {
      foreach::`%do%`
    }

    foreach::foreach(s = Symbols) %fi_foreach% {

        if (verbose) message("converting ", s)
        gdir <- paste(getdir, s, sep=gsep)
        if (file.exists(gdir)) {
            sdir <- paste(savedir, s, sep=ssep)
            if (!file.exists(sdir)) dir.create(sdir) #create dir for symbol if it doesn't exist
            fls <- list.files(gdir)
            fls <- fls[!fls %in% c("Bid.Image", "Ask.Image", "Price.Image")]
            tmpenv <- new.env()
            unname(sapply(fls, function(fl) {
                if (!file.exists(paste(sdir, fl, sep='/')) || overwrite) {
                    xsym <- try(load(paste(gdir, fl, sep="/")))
                    if (!inherits(xsym, 'try-error') && !is.null(get(xsym))) {
                        #x <- to_secBATMV(get(xsym))
                        x <- try(to_secBATV(get(xsym)), silent=TRUE)
                        if (!inherits(x, 'try-error')) {
                            assign(xsym, x, pos=tmpenv)
                            sfl <- paste(sdir, fl, sep="/")
                            save(list = xsym, file = sfl, envir = tmpenv)
                            rm(xsym, pos=tmpenv)
                            rm(list='x')
                            gc()
                            fl
                        }
                    }
                } else warning(paste(sdir, '/', fl,
                    " already exists and will not be overwritten. Use overwrite=TRUE to overwrite.", sep=""))
            }))
        } else warning(paste(gdir, 'does not exist'))
    }
}
