#' @noRd
has.Mid <- function (x, which = FALSE) {
  colAttr <- attr(x, "Mid")
  if (!is.null(colAttr))
    return(if (which) colAttr else TRUE)
  loc <- grep("Mid", colnames(x), ignore.case = TRUE)
  if (!identical(loc, integer(0)))
    return(ifelse(which, loc, TRUE))
  ifelse(which, loc, FALSE)
}

#' @noRd
convert.time.series <- function (fr, return.class) {
  if ("quantmod.OHLC" %in% return.class) {
    class(fr) <- c("quantmod.OHLC", "zoo")
    return(fr)
  }
  else if ("xts" %in% return.class) {
    return(fr)
  }
  if ("zoo" %in% return.class) {
    return(as.zoo(fr))
  }
  else if ("ts" %in% return.class) {
    fr <- as.ts(fr)
    return(fr)
  }
  else if ("data.frame" %in% return.class) {
    fr <- as.data.frame(fr)
    return(fr)
  }
  else if ("matrix" %in% return.class) {
    fr <- as.data.frame(fr)
    return(fr)
  }
  else if ("timeSeries" %in% return.class) {
    if (requireNamespace("timeSeries", quietly = TRUE)) {
      fr <- timeSeries::timeSeries(coredata(fr), charvec = as.character(index(fr)))
      return(fr)
    }
    else {
      warning(paste("'timeSeries' from package 'timeSeries' could not be loaded:",
                    " 'xts' class returned"))
    }
  }
}
