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

#' Save data to disk
#'
#' Save data to disk the way that \code{getSymbols.FI}
#' expects it to be saved.
#'
#' If they do not already exist, subdirectories will be created for each of the
#' \code{Symbols}.  \code{saveSymbols.common} will save a single \sQuote{rda}
#' file for each of the \code{Symbols} in that symbol's subdirectory.
#' \code{saveSymbols.days} will split the data up into days and save a separate
#' \sQuote{rda} file for each day in that symbol's subdirectory.
#'
#' @param Symbols character vector of names of objects to be saved
#' @param base_dir character.  directory in which to store data.
#' @param extension file extension (\dQuote{rda})
#' @param env environment that holds the data to be saved (.GlobalEnv by default)
#' @return called for side-effect.
#' @seealso \code{\link{getSymbols.FI}}
#' @examples
#' example_dir <- tempfile("fi-symbol-data-")
#' dir.create(example_dir)
#'
#' example_env <- new.env()
#'
#' example_env$SPY <- xts::xts(
#'   matrix(
#'     1:8,
#'     ncol = 2L,
#'     dimnames = list(
#'       NULL,
#'       c("Close", "Volume")
#'     )
#'   ),
#'   order.by = as.Date("2020-01-01") + 0:3
#' )
#'
#' tryCatch(
#'   {
#'     saveSymbols.common(
#'       "SPY",
#'       base_dir = example_dir,
#'       env = example_env
#'     )
#'
#'     list.files(
#'       example_dir,
#'       recursive = TRUE
#'     )
#'   },
#'   finally = {
#'     unlink(example_dir, recursive = TRUE)
#'   }
#' )
#'
#' @export
#' @rdname saveSymbols.days
saveSymbols.days <-
function(Symbols, base_dir="", extension="rda", env=.GlobalEnv) {
    if (base_dir != "" &&
        !is.null(base_dir) &&
        substr(base_dir,nchar(base_dir),nchar(base_dir)) != "/")
            base_dir <- paste(base_dir,"/",sep="")
    tmpenv <- new.env()
    for (symbol in Symbols) {
        tmp <- try(get(symbol,pos=env), silent=TRUE)
        if (!is.null(tmp) && !inherits(tmp,'try-error')) {
            D <- split(tmp,'days')
            if (!file.exists(paste(base_dir,symbol,sep=""))) dir.create(paste(base_dir,symbol,sep=""))
            fnames <- paste(base_dir,symbol,"/",
                    unlist(lapply(D, FUN=function(x) format(index(first(x)),"%Y.%m.%d"))),
                    ".", symbol, ".", extension, sep="")
            for (i in 1:length(fnames)) {
                assign(symbol,D[[i]],envir=tmpenv)
                save(list=symbol,file=fnames[i],envir=tmpenv)
            }
        } else if (inherits(tmp, 'try-error')) warning(paste(symbol, "could not be found in 'env' and was not saved."))
    }
}

#' @export
#' @rdname saveSymbols.days
saveSymbols.common <- function (Symbols, base_dir = "", extension="rda", env = .GlobalEnv)
{
    if (base_dir != "" && !is.null(base_dir) && substr(base_dir,
        nchar(base_dir), nchar(base_dir)) != "/")
        base_dir <- paste(base_dir, "/", sep = "")
    tmpenv <- new.env()
    for (symbol in Symbols) {
        tmp <- try(get(symbol, pos = env), silent=TRUE)
        if (!is.null(tmp) && !inherits(tmp, "try-error")) {
            if (!file.exists(paste(base_dir, symbol, sep = "")))
                dir.create(paste(base_dir, symbol, sep = ""))
            fnames <- paste(base_dir, symbol, "/", symbol, ".", extension, sep = "")
            assign(symbol, tmp, envir = tmpenv)
            save(list = symbol, file = fnames, envir = tmpenv)
        } else if (inherits(tmp, 'try-error')) warning(paste(symbol, "could not be found in 'env' and was not saved."))
    }
}


