#' Find attributes that more than one instrument have in common
#' @param Symbols character vector of primary_ids of instruments
#' @param \dots arguments to pass to
#'   \code{\link[FinancialInstrument]{getInstrument}}
#' @return character vector of names of attributes that all \code{Symbols}'
#'   instruments have in common
#' @author gsee
#' @note I really do not like the name of this function, so if it survives, its
#'   name may change
FindCommonInstrumentAttributes <- function(Symbols, ...) {
    i <- lapply(Symbols, getInstrument, ...)
    n <- lapply(i, names)
    Reduce(intersect, n)
}
