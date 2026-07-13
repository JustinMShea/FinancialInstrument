# Internal validation helpers for futures series.
#
# These functions intentionally preserve the package's existing storage
# conventions. In particular, YYYY-MM expiration values remain valid and are
# not coerced before being stored on an instrument.

.parse_instrument_date <- function(x, argument) {
  if (is.null(x)) {
    return(NULL)
  }

  if (length(x) == 0L || any(is.na(x))) {
    stop("'", argument, "' must not contain missing values", call. = FALSE)
  }

  if (inherits(x, "Date")) {
    values <- format(x, "%Y-%m-%d")
  } else if (inherits(x, "POSIXt")) {
    values <- format(as.Date(x), "%Y-%m-%d")
  } else if (is.character(x)) {
    values <- x
  } else {
    stop(
      "'", argument, "' must be a Date, POSIXt, or character value",
      call. = FALSE
    )
  }

  parse_one <- function(value) {
    value <- gsub("^[[:space:]]+|[[:space:]]+$", "", value)

    if (!nzchar(value)) {
      stop("'", argument, "' must not contain empty values", call. = FALSE)
    }

    if (grepl("^[0-9]{4}-[0-9]{2}$", value)) {
      year <- as.integer(substr(value, 1L, 4L))
      month <- as.integer(substr(value, 6L, 7L))
      precision <- "month"

      if (month < 1L || month > 12L) {
        stop(
          "'", argument, "' contains an invalid date: ", sQuote(value),
          call. = FALSE
        )
      }

      date_value <- as.Date(sprintf("%04d-%02d-01", year, month))
    } else if (grepl("^[0-9]{6}$", value)) {
      year <- as.integer(substr(value, 1L, 4L))
      month <- as.integer(substr(value, 5L, 6L))
      precision <- "month"

      if (month < 1L || month > 12L) {
        stop(
          "'", argument, "' contains an invalid date: ", sQuote(value),
          call. = FALSE
        )
      }

      date_value <- as.Date(sprintf("%04d-%02d-01", year, month))
    } else if (grepl("^[0-9]{8}$", value)) {
      date_value <- try(as.Date(value, format = "%Y%m%d"), silent = TRUE)

      if (inherits(date_value, "try-error") || is.na(date_value)) {
        stop(
          "'", argument, "' contains an invalid date: ", sQuote(value),
          call. = FALSE
        )
      }

      year <- as.integer(format(date_value, "%Y"))
      month <- as.integer(format(date_value, "%m"))
      precision <- "day"
    } else {
      date_value <- try(as.Date(value), silent = TRUE)

      if (inherits(date_value, "try-error") || is.na(date_value)) {
        stop(
          "'", argument, "' contains a value that cannot be converted to Date: ",
          sQuote(value),
          call. = FALSE
        )
      }

      year <- as.integer(format(date_value, "%Y"))
      month <- as.integer(format(date_value, "%m"))
      precision <- "day"
    }

    if (is.na(month) || month < 1L || month > 12L || is.na(date_value)) {
      stop(
        "'", argument, "' contains an invalid date: ", sQuote(value),
        call. = FALSE
      )
    }

    data.frame(
      original = value,
      date = date_value,
      year = year,
      month = month,
      precision = precision,
      stringsAsFactors = FALSE
    )
  }

  do.call(rbind, lapply(values, parse_one))
}

.parse_future_suffix <- function(suffix_id) {
  if (!is.character(suffix_id) || length(suffix_id) != 1L ||
      is.na(suffix_id) || !nzchar(suffix_id)) {
    stop("'suffix_id' must be a single non-empty character value", call. = FALSE)
  }

  parsed <- try(parse_suffix(suffix_id, silent = TRUE), silent = TRUE)

  if (inherits(parsed, "try-error") || is.null(parsed$format) ||
      length(parsed$format) == 0L || is.na(parsed$format)) {
    stop(
      "'suffix_id' is not a recognized futures suffix: ", sQuote(suffix_id),
      call. = FALSE
    )
  }

  month <- match(toupper(parsed$month), toupper(month.abb))
  year <- suppressWarnings(as.integer(parsed$year))
  types <- parsed$type

  dated_outright <-
    "outright" %in% types &&
    !any(c("spread", "option", "cm", "cc") %in% types) &&
    length(month) == 1L && !is.na(month) &&
    length(year) == 1L && !is.na(year) && year > 0L

  list(
    suffix_id = suffix_id,
    type = types,
    format = parsed$format,
    month = if (dated_outright) month else NA_integer_,
    year = if (dated_outright) year else NA_integer_,
    dated_outright = dated_outright
  )
}

.validate_future_series_dates <- function(suffix_id, first_traded = NULL,
                                          expires = NULL) {
  suffix <- .parse_future_suffix(suffix_id)
  first_info <- .parse_instrument_date(first_traded, "first_traded")
  expiry_info <- .parse_instrument_date(expires, "expires")

  if (suffix$dated_outright && !is.null(expiry_info)) {
    mismatch <- expiry_info$year != suffix$year |
      expiry_info$month != suffix$month

    if (any(mismatch)) {
      supplied_months <- unique(paste(
        month.name[expiry_info$month[mismatch]],
        expiry_info$year[mismatch]
      ))

      warning(
        "suffix_id ", sQuote(suffix_id), " indicates ",
        month.name[suffix$month], " ", suffix$year,
        ", but 'expires' indicates ",
        paste(supplied_months, collapse = ", "),
        call. = FALSE
      )
    }
  }

  if (!is.null(first_info) && !is.null(expiry_info) &&
      nrow(first_info) == 1L && nrow(expiry_info) == 1L &&
      first_info$date > expiry_info$date) {
    stop("'first_traded' must not be after 'expires'", call. = FALSE)
  }

  invisible(TRUE)
}
