# Internal validation helpers for option series instruments.

.option_series_date <- function(x, argument, allow_multiple = FALSE) {
    if (is.null(x)) return(NULL)

    if (inherits(x, "POSIXlt")) {
        x <- as.POSIXct(x)
    }

    if (!allow_multiple && length(x) != 1L) {
        stop("'", argument, "' must be a single date", call. = FALSE)
    }
    if (length(x) < 1L || anyNA(x)) {
        stop("'", argument, "' must not contain missing values", call. = FALSE)
    }
  parse_one <- function(value) {
    if (inherits(value, "Date")) {
      return(value)
    }

    if (inherits(value, "POSIXt")) {
      tz <- attr(value, "tzone")

      if (is.null(tz) || length(tz) == 0L ||
          is.na(tz[[1L]]) || !nzchar(tz[[1L]])) {
        tz <- "UTC"
      } else {
        tz <- tz[[1L]]
      }

      return(as.Date(value, tz = tz))
    }

    value <- as.character(value)

        parsed <- tryCatch(
            if (grepl("^[0-9]{8}$", value)) {
                as.Date(value, format = "%Y%m%d")
            } else {
                suppressWarnings(as.Date(value))
            },
            error = function(e) as.Date(NA)
        )

        if (is.na(parsed)) {
            stop("'", argument, "' must be coercible to Date", call. = FALSE)
        }
        parsed
    }

    as.Date(vapply(as.list(x), parse_one, as.Date("1970-01-01")),
            origin = "1970-01-01")
}

.normalize_option_callput <- function(callput, allow_default = TRUE) {
    if (allow_default && length(callput) == 2L &&
            identical(tolower(callput), c("call", "put"))) {
        return(NULL)
    }
    if (length(callput) != 1L || is.na(callput)) {
        stop("'callput' must be a single value: 'call', 'put', 'C', or 'P'",
             call. = FALSE)
    }

    normalized <- switch(tolower(as.character(callput)),
                         c = "call",
                         call = "call",
                         p = "put",
                         put = "put",
                         NULL)
    if (is.null(normalized)) {
        stop("'callput' must be one of 'call', 'put', 'C', or 'P'",
             call. = FALSE)
    }
    normalized
}

.validate_option_strike <- function(strike) {
    if (is.null(strike)) return(NULL)
    if (!is.numeric(strike) || length(strike) != 1L ||
            is.na(strike) || !is.finite(strike) || strike <= 0) {
        stop("'strike' must be a single positive number", call. = FALSE)
    }
    strike
}

.parse_option_suffix <- function(suffix_id) {
    if (is.null(suffix_id) || length(suffix_id) != 1L ||
            is.na(suffix_id) || !nzchar(suffix_id)) {
        stop("'suffix_id' must identify a single option contract",
             call. = FALSE)
    }

    parsed <- suppressWarnings(
        try(parse_suffix(suffix_id, silent = TRUE), silent = TRUE)
    )
    if (inherits(parsed, "try-error") || is.null(parsed) ||
            !all(c("outright", "option") %in% parsed$type) ||
            length(parsed$format) != 1L || is.na(parsed$format) ||
            !parsed$format %in% c("opt2", "opt4")) {
        stop("'suffix_id' must identify an outright option contract",
             call. = FALSE)
    }

    day <- if (identical(parsed$format, "opt2")) {
        substr(suffix_id, 5L, 6L)
    } else {
        substr(suffix_id, 7L, 8L)
    }

    expiration_text <- sprintf(
        "%04d-%02d-%02d",
        parsed$year,
        match(parsed$month, toupper(month.abb)),
        as.integer(day)
    )
    expiration <- tryCatch(
        suppressWarnings(as.Date(expiration_text)),
        error = function(e) as.Date(NA)
    )
    if (is.na(expiration)) {
        stop("'suffix_id' contains an invalid option expiration date",
             call. = FALSE)
    }

    parsed_callput <- switch(parsed$right, C = "call", P = "put", NULL)
    if (is.null(parsed_callput) || !is.numeric(parsed$strike) ||
            length(parsed$strike) != 1L || is.na(parsed$strike) ||
            !is.finite(parsed$strike) || parsed$strike <= 0) {
        stop("'suffix_id' contains invalid option contract fields",
             call. = FALSE)
    }

    list(
        expiration = expiration,
        callput = parsed_callput,
        strike = parsed$strike,
        parsed = parsed
    )
}

.validate_option_series_fields <- function(suffix_id, expires = NULL,
                                           first_traded = NULL,
                                           callput = c("call", "put"),
                                           strike = NULL) {
    suffix <- .parse_option_suffix(suffix_id)

    explicit_expiration <- .option_series_date(expires, "expires")
    expiration <- if (is.null(explicit_expiration)) {
        suffix$expiration
    } else {
        if (!identical(explicit_expiration, suffix$expiration)) {
            warning(
                "suffix_id '", suffix_id, "' indicates expiration ",
                format(suffix$expiration), ", but expires is ",
                format(explicit_expiration),
                call. = FALSE
            )
        }
        explicit_expiration
    }

    traded <- .option_series_date(first_traded, "first_traded",
                                  allow_multiple = TRUE)
    if (!is.null(traded) && any(traded > expiration)) {
        stop("'first_traded' must not be later than 'expires'",
             call. = FALSE)
    }

    explicit_callput <- .normalize_option_callput(callput)
    resolved_callput <- if (is.null(explicit_callput)) {
        suffix$callput
    } else {
        if (!identical(explicit_callput, suffix$callput)) {
            warning(
                "suffix_id '", suffix_id, "' indicates a ",
                suffix$callput, ", but callput is '", explicit_callput, "'",
                call. = FALSE
            )
        }
        explicit_callput
    }

    explicit_strike <- .validate_option_strike(strike)
    resolved_strike <- if (is.null(explicit_strike)) {
        suffix$strike
    } else {
        if (!isTRUE(all.equal(explicit_strike, suffix$strike,
                              tolerance = sqrt(.Machine$double.eps)))) {
            warning(
                "suffix_id '", suffix_id, "' indicates strike ",
                format(suffix$strike), ", but strike is ",
                format(explicit_strike),
                call. = FALSE
            )
        }
        explicit_strike
    }

    list(
        expires = format(expiration),
        callput = resolved_callput,
        strike = resolved_strike
    )
}
