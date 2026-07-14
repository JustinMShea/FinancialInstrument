# option_series() contract identity and validation

rm_instruments(keep.currencies = FALSE)
currency("USD")
stock("SPY", "USD")
option(
    ".SPY",
    currency = "USD",
    multiplier = 100,
    tick_size = 0.01,
    underlying_id = "SPY"
)

# Constructing from fields creates an exact-date option identifier.
created <- option_series(
    root_id = ".SPY",
    expires = "2027-01-15",
    callput = "call",
    strike = 600
)
expect_identical(created, "SPY_270115C600")

contract <- getInstrument(created, type = "option_series")
expect_inherits(contract, "option_series")
expect_inherits(contract, "option")
expect_identical(contract$root_id, ".SPY")
expect_identical(contract$suffix_id, "270115C600")
expect_identical(contract$expires, "2027-01-15")
expect_identical(contract$callput, "call")
expect_equal(contract$strike, 600)
expect_identical(contract$currency, "USD")
expect_equal(contract$multiplier, 100)
expect_equal(contract$tick_size, 0.01)
expect_identical(contract$underlying_id, "SPY")

# A complete option identifier supplies the exact expiration date, right,
# and strike rather than reducing expiration to year-month.
parsed <- option_series(
    "SPY_270115P550",
    root_id = ".SPY",
    assign_i = FALSE
)
expect_inherits(parsed, "option_series")
expect_identical(parsed$expires, "2027-01-15")
expect_identical(parsed$callput, "put")
expect_equal(parsed$strike, 550)

# Four-digit years and OSI-style fixed-width strikes are supported.
osi <- option_series(
    "SPY_20270115C00600000",
    root_id = ".SPY",
    assign_i = FALSE
)
expect_identical(osi$expires, "2027-01-15")
expect_identical(osi$callput, "call")
expect_equal(osi$strike, 600)

# Common call/put aliases are normalized when fields are used to construct
# the identifier.
alias_contract <- option_series(
    root_id = ".SPY",
    expires = "2027-02-19",
    callput = "P",
    strike = 500,
    assign_i = FALSE
)
expect_identical(alias_contract$primary_id, "SPY_270219P500")
expect_identical(alias_contract$callput, "put")

# Explicit fields that conflict with the identifier are retained for backward
# compatibility, but the inconsistency is reported.
expect_warning(
    option_series(
        "SPY_270115C600",
        root_id = ".SPY",
        expires = "2027-01-16",
        assign_i = FALSE
    ),
    "indicates expiration 2027-01-15"
)
expect_warning(
    option_series(
        "SPY_270115C600",
        root_id = ".SPY",
        callput = "put",
        assign_i = FALSE
    ),
    "indicates a call"
)
expect_warning(
    option_series(
        "SPY_270115C600",
        root_id = ".SPY",
        strike = 601,
        assign_i = FALSE
    ),
    "indicates strike 600"
)

# Invalid contract fields fail with domain-specific messages.
expect_error(
    option_series(
        root_id = ".SPY",
        expires = "not-a-date",
        callput = "call",
        strike = 600,
        assign_i = FALSE
    ),
    "coercible to Date"
)
expect_error(
    option_series(
        root_id = ".SPY",
        expires = "2027-01-15",
        callput = "neither",
        strike = 600,
        assign_i = FALSE
    ),
    "must be one of"
)
expect_error(
    option_series(
        root_id = ".SPY",
        expires = "2027-01-15",
        callput = "call",
        strike = 0,
        assign_i = FALSE
    ),
    "positive number"
)
expect_error(
    option_series(
        "SPY_270231C600",
        root_id = ".SPY",
        assign_i = FALSE
    ),
    "invalid option expiration date"
)
expect_error(
    option_series(
        "SPY_270115C600",
        root_id = ".SPY",
        first_traded = "2027-01-16",
        assign_i = FALSE
    ),
    "must not be later"
)
expect_error(
    option_series(
        "SPY_BAD",
        root_id = ".SPY",
        assign_i = FALSE
    ),
    "option contract"
)

# Listed option expirations require an exact calendar date.
expect_error(
  option_series(
    "SPY_270319C600",
    root_id = ".SPY",
    expires = "2027-03",
    assign_i = FALSE
  ),
  "coercible to Date"
)


# POSIXct expiration values are accepted.
posix_expiry <- as.POSIXct(
  "2027-03-19 16:00:00",
  tz = "America/Chicago"
)

posix_contract <- option_series(
  "SPY_270319C600",
  root_id = ".SPY",
  expires = posix_expiry,
  assign_i = FALSE
)

expect_equal(
  as.Date(posix_contract$expires),
  as.Date("2027-03-19")
)

# POSIXlt values are also accepted.
posixlt_expiry <- as.POSIXlt(
  "2027-03-19 16:00:00",
  tz = "America/Chicago"
)

posixlt_contract <- option_series(
  "SPY_270319C600",
  root_id = ".SPY",
  expires = posixlt_expiry,
  assign_i = FALSE
)

expect_equal(
  as.Date(posixlt_contract$expires),
  as.Date("2027-03-19")
)


expect_silent(
  option_series(
    "SPY_270319C600",
    root_id = ".SPY",
    expires = as.Date("2027-03-19"),
    first_traded = as.POSIXct(
      "2027-03-01 09:30:00",
      tz = "America/New_York"
    ),
    assign_i = FALSE
  )
)

rm_instruments(keep.currencies = FALSE)
