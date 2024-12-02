# tests/testthat/test-calculate_WDI.R

library(testthat)
library(wdiEF)

test_that("calculate_WDI works correctly", {
  # Get the file paths
  FVC_path <- system.file("extdata", "FVC_reduced.tif", package = "wdiEF")
  TS_TA_path <- system.file("extdata", "TS_TA_reduced.tif", package = "wdiEF")

  # Check if the files exist
  expect_true(file.exists(FVC_path), "The file FVC_reduced.tif was not found.")
  expect_true(file.exists(TS_TA_path), "The file TS_TA_reduced.tif was not found.")

  # Load the rasters
  library(terra)
  FVC <- rast(FVC_path)
  TS_TA <- rast(TS_TA_path)

  # Output path (temporary file for test purposes)
  output_path <- tempfile(fileext = ".tif")

  # Test the calculate_WDI function
  result <- calculate_WDI(
    FVC_path = FVC_path,
    TS_TA_path = TS_TA_path,
    output_path = output_path,
    n_intervals = 20,
    percentile = 0.01
  )

  # Check if the output file was created
  expect_true(file.exists(output_path), "The output WDI raster file was not created.")

  # Load the output raster to check values
  output_raster <- rast(output_path)

  # Check if all values in the output raster are between 0 and 1
  values_output <- values(output_raster)
  expect_true(all(values_output >= 0 & values_output <= 1, na.rm = TRUE),
              "Output raster values are not between 0 and 1.")
})
