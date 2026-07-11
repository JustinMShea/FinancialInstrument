# month codes

expect_identical(unname(C2M()), month.abb)
expect_identical(names(C2M()),
                 c("F", "G", "H", "J", "K", "M", "N", "Q", "U", "V", "X", "Z"))
