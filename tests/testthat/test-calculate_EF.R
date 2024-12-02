
# tests/testthat/test-calculate_EF.R

library(testthat)
library(wdiEF)

test_that("calculate_EF works correctly", {
  FVC_path <- system.file("extdata", "FVC_reduced.tif", package = "wdiEF")
  TS_TA_path <- system.file("extdata", "TS_TA_reduced.tif", package = "wdiEF")

  # Check if the files exist
  expect_true(file.exists(FVC_path), "The file FVC_reduced.tif was not found.")
  expect_true(file.exists(TS_TA_path), "The file TS_TA_reduced.tif was not found.")

  # Load the rasters
  FVC <- rast(FVC_path)
  TS_TA <- rast(TS_TA_path)

  # Test the function
  output_path <- tempfile(fileext = ".tif")
  result <- calculate_EF(FVC, TS_TA, output_path, n_intervals = 20, percentile = 0.01)
  expect_true(file.exists(output_path))
})
