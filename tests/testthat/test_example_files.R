
test_that("the example files are loaded correctly", {
  library(terra)

  # Path management based on the mode (development or installed package)
  if (dir.exists("inst/extdata")) {
    # Development mode: Files are in the 'inst/extdata' directory
    FVC_path <- normalizePath(file.path(getwd(), "inst", "extdata", "FVC_reduced.tif"))
    TS_TA_path <- normalizePath(file.path(getwd(), "inst", "extdata", "TS_TA_reduced.tif"))
  } else {
    # Package installed mode: Files are installed via the package
    FVC_path <- system.file("extdata", "FVC_reduced.tif", package = "wdiEF")
    TS_TA_path <- system.file("extdata", "TS_TA_reduced.tif", package = "wdiEF")
  }

  # Load the rasters
  FVC <- rast(FVC_path)
  TS_TA <- rast(TS_TA_path)

  # Check if the files exist
  expect_true(file.exists(FVC_path), info = "FVC_reduced.tif file not found")
  expect_true(file.exists(TS_TA_path), info = "TS_TA_reduced.tif file not found")

  # Check the object classes
  expect_s4_class(FVC, "SpatRaster")
  expect_s4_class(TS_TA, "SpatRaster")
})

