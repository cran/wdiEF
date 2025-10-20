#' Calculate the Water Deficit Index (WDI)
#'
#' This function calculates the WDI from two rasters: fractional vegetation cover (FVC)
#' and the surface-air temperature difference (TS-TA). It saves the resulting
#' WDI raster to the specified output path.
#'
#' @param FVC_path Character. File path to the FVC raster.Must have the same
#'        CRS and extent as the TS-TA raster.
#' @param TS_TA_path Character. File path to the raster of TS-TA (surface-air temperature difference).
#'        TS and TA must have the same unit of measurement (Kelvin preferably).
#' @details
#' - The input rasters (`FVC` and `TS-TA`) must have the same CRS (Coordinate Reference System) and extent.
#' - If they differ, the function will attempt to reproject and resample the rasters automatically.
#' @param output_path Character. File path where the WDI raster will be saved.
#' @param n_intervals Integer. Number of intervals for splitting FVC values
#'        (default: 20).
#' @param percentile Numeric. Percentage used for identifying wet and dry edges
#'        (default: 0.01).
#'
#' @return A raster object representing the Water Deficit Index (WDI).
#'
#' @importFrom terra rast resample values varnames writeRaster
#' @importFrom dplyr "%>%"
#' @importFrom stats lm coef na.omit weighted.mean
#' @importFrom stats na.exclude
#'
#'
#' @examples
#' # Paths to example data included in the package
#' library(terra)
#'
#' FVC_raster <- rast(system.file("extdata", "FVC_reduced.tif", package = "wdiEF"))
#' TS_TA_raster <- rast(system.file("extdata", "TS_TA_reduced.tif", package = "wdiEF"))
#'
#'
#' # Output path (temporary file for example purposes)
#' output_path <- tempfile(fileext = ".tif")
#'
#' # Run the function
#' calculate_WDI(
#'   FVC_path = FVC_raster,
#'   TS_TA_path = TS_TA_raster,
#'   output_path = output_path,
#'   n_intervals = 20,
#'   percentile = 0.01
#' )
#'
#' # Print the output path
#' print(output_path)
#'
#' @export
calculate_WDI <- function(FVC_path, TS_TA_path, output_path, n_intervals = 20, percentile = 0.01) {

  # Step 1: Load rasters from paths or use already loaded SpatRaster
  if (inherits(FVC_path, "character") && file.exists(FVC_path)) {
    FVC <- rast(FVC_path)
  } else if (inherits(FVC_path, "SpatRaster")) {
    FVC <- FVC_path
  } else {
    stop("Invalid FVC input.")
  }

  if (inherits(TS_TA_path, "character") && file.exists(TS_TA_path)) {
    TS_TA <- rast(TS_TA_path)
  } else if (inherits(TS_TA_path, "SpatRaster")) {
    TS_TA <- TS_TA_path
  } else {
    stop("Invalid TS_TA input.")
  }

  # Step 2: Align CRS silently
  if (!terra::same.crs(FVC, TS_TA)) {
    TS_TA <- terra::project(TS_TA, terra::crs(FVC))
  }

  # Step 3: Align extent silently
  if (!terra::ext(FVC) == terra::ext(TS_TA)) {
    TS_TA <- terra::resample(TS_TA, FVC)
  }

  # Step 4: Clip FVC to [0,1] and normalize silently if max < 1
  FVC[FVC > 1] <- 1
  FVC[FVC < 0] <- 0
  max_FVC <- max(terra::values(FVC), na.rm = TRUE)
  if (max_FVC < 1) {
    FVC <- FVC / max_FVC
  }

  # Step 5: Convert rasters to vectors
  values_FVC <- terra::values(FVC)
  values_TS_TA <- terra::values(TS_TA)

  # Step 6: Cut FVC into intervals and calculate wet/dry temperatures
  cut_fvc <- cut(values_FVC, breaks = n_intervals)
  R1 <- data.frame()
  ligne <- 1

  for (i in 1:n_intervals) {
    idx <- which(cut_fvc == levels(cut_fvc)[i])
    ts_values <- values_TS_TA[idx]
    ts_values <- ts_values[!is.na(ts_values)]

    if (length(ts_values) > 0) {
      ts_sorted <- sort(ts_values)
      n <- length(ts_sorted)
      low_vals <- ts_sorted[1:floor(percentile * n)]
      high_vals <- ts_sorted[ceiling((1 - percentile) * n):n]

      R1[ligne, "Interval"] <- i
      R1[ligne, "Ts_wet"] <- mean(low_vals, na.rm = TRUE)
      R1[ligne, "Ts_dry"] <- mean(high_vals, na.rm = TRUE)
    } else {
      R1[ligne, "Interval"] <- i
      R1[ligne, "Ts_wet"] <- NA
      R1[ligne, "Ts_dry"] <- NA
    }
    ligne <- ligne + 1
  }

  # Step 7: Assign FVC midpoints for regression
  R1$FVC <- seq(0.5 / n_intervals, 1 - 0.5 / n_intervals, length.out = n_intervals)

  # Step 8: Remove first two intervals (very low FVC, bare soil)
  R1[1:2, c("Ts_wet", "Ts_dry")] <- NA

  # Step 9: Fit linear regression for wet and dry edges
  reg_wet <- lm(Ts_wet ~ FVC, data = R1, na.action = na.exclude)
  reg_dry <- lm(Ts_dry ~ FVC, data = R1, na.action = na.exclude)

  # Step 10: Extract regression coefficients
  a_wet <- coef(reg_wet)[2]; b_wet <- coef(reg_wet)[1]
  a_dry <- coef(reg_dry)[2]; b_dry <- coef(reg_dry)[1]

  # Step 11: Compute WDI raster
  WDI <- (TS_TA - ((a_wet * FVC) + b_wet)) /
    (((a_dry * FVC) + b_dry) - ((a_wet * FVC) + b_wet))

  # Step 12: Clip WDI to [0,1]
  WDI[WDI > 1] <- 1
  WDI[WDI < 0] <- 0
  names(WDI) <- "WDI"
  terra::varnames(WDI) <- "WDI"

  # Step 13: Save WDI raster
  terra::writeRaster(WDI, output_path, overwrite = TRUE)

  # Step 14: Plot WDI raster
  terra::plot(WDI, main = "WDI (Water Deficit Index)")

  # Step 15: Return WDI raster
  return(WDI)
}
