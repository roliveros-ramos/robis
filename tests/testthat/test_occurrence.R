library(obisclient)
context("occurrence")

small_test_species <- "Abra sibogai"
small_test_aphiaid <- 345684
other_test_aphiaid <- 141438 # Abra segmentum

test_that("occurrence returns small number of records for a scientific name", {
  records <- occurrence(scientificname = small_test_species, verbose = TRUE)
  expect_more_than(nrow(records), 0)
  expect_true(is.data.frame(records))
  expect_true(all(records$scientificName == small_test_species))
  expect_true(all(records$aphiaID == small_test_aphiaid))
})

test_that("occurrence returns small number of records for an aphia id", {
  records <- occurrence(aphiaid = small_test_aphiaid)
  expect_more_than(nrow(records), 0)
  expect_true(is.data.frame(records))
  expect_true(all(records$aphiaID == small_test_aphiaid))
})

test_that("occurrence returns small number of records for an obis id", {
  records <- occurrence(aphiaid = small_test_aphiaid) ## obis ids are not stable so taking a detour
  records <- occurrence(obisid = records$obisID[1])
  expect_more_than(nrow(records), 0)
  expect_true(is.data.frame(records))
  expect_true(all(records$taxonID == records$obisID[1]))
  expect_true(all(records$aphiaID == small_test_aphiaid))
})

test_that("occurrence returns records filtered on year",{
  records <- occurrence(aphiaid = other_test_aphiaid, year = 1935)
  expect_more_than(nrow(records), 0)
  expect_true(all(records$yearcollected == 1935))
})

test_that("occurrence returns records filtered on year",{
  records <- occurrence(aphiaid = other_test_aphiaid)
  year <- na.omit(records$yearcollected)[1]
  records <- occurrence(aphiaid = other_test_aphiaid, year = year)
  expect_more_than(year, 0)
  expect_more_than(nrow(records), 0)
  expect_true(all(records$yearcollected == year))
})

test_that("qc flags in queries are respected", {
  records <- occurrence(scientificname = small_test_species)

  check_qc_no_zero <- function(records) {
    qc_ok <- sapply(1:30, function(qc) { c(row=bitwAnd(records$qc, 2^(qc-1)) > 0) })
    which(colSums(qc_ok) < nrow(qc_ok) & colSums(qc_ok) != 0)
  }
  qc_numbers_not_ok <- check_qc_no_zero(records)
  records_with_qc <- occurrence(scientificname = "Abra sibogai", qc=qc_numbers_not_ok)
  expect_equal(length(check_qc_no_zero(records_with_qc)), 0)
  expect_less_than(nrow(records_with_qc), nrow(records))
})

test_that("occurrence test warnings",{
  expect_warning({occurrence(aphiaid = -1)})
  expect_warning({occurrence(aphiaid = small_test_aphiaid, year = NA)})
  expect_warning({occurrence(aphiaid = small_test_aphiaid, year = "test")})
})