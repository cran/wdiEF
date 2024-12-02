#' Calculate the Evaporative Fraction (EF)
#'
#' This function calculates the EF from two rasters: fractional vegetation cover (FVC)
#' and the surface-air temperature difference (TS-TA). It saves the resulting
#' EF raster to the specified output path.
#'
#' @param FVC_path Character. File path to the FVC raster.Must have the same
#'        CRS and extent as the TS-TA raster.
#' @param TS_TA_path Character. File path to the raster of TS-TA (surface-air temperature difference).
#'        TS and TA must have the same unit of measurement (Kelvin preferably).
#' @details
#' - The input rasters (`FVC` and `TS-TA`) must have the same CRS (Coordinate Reference System) and extent.
#' - If they differ, the function will attempt to reproject and resample the rasters automatically.
#' @param output_path Character. File path where the EF raster will be saved.
#' @param n_intervals Integer. Number of intervals for splitting FVC values
#'        (default: 20).
#' @param percentile Numeric. Percentage used for identifying wet and dry edges
#'        (default: 0.01).
#'
#' @return A raster object representing the Evaporative Fraction (EF).
#'
#' @importFrom terra rast resample values varnames writeRaster
#' @importFrom dplyr "%>%"
#' @importFrom stats lm coef na.omit weighted.mean
#'
#'
#'
#' @examples
#' # Paths to example data included in the package
#' library(terra)
#'
#'FVC_raster <- rast(system.file("extdata", "FVC_reduced.tif", package = "wdiEF"))
#'TS_TA_raster <- rast(system.file("extdata", "TS_TA_reduced.tif", package = "wdiEF"))
#'
#' # Output path (temporary file for example purposes)
#' output_path <- tempfile(fileext = ".tif")
#'
#' # Run the function
#' calculate_EF(
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
calculate_EF <- function(FVC_path, TS_TA_path,output_path, n_intervals = 20, percentile = 0.01) {

    # If paths are provided, load rasters
    if (inherits(FVC_path, "character") && file.exists(FVC_path)) {
      FVC <- rast(FVC_path)
    } else if (inherits(FVC_path, "SpatRaster")) {
      FVC <- FVC_path  # already loaded raster
    } else {
      stop("Invalid FVC input.")
    }

    if (inherits(TS_TA_path, "character") && file.exists(TS_TA_path)) {
      TS_TA <- rast(TS_TA_path)
    } else if (inherits(TS_TA_path, "SpatRaster")) {
      TS_TA <- TS_TA_path  # already loaded raster
    } else {
      stop("Invalid TS_TA input.")
    }

    # Check if rasters have the same CRS and extent

  if (!terra::same.crs(FVC, TS_TA)) {
    warning("Different CRS detected. The rasters will be reprojected to align.")
    TS_TA <- terra::project(TS_TA, terra::crs(FVC))
  }

  if (!terra::ext(FVC) == terra::ext(TS_TA)) {
    warning("The extents do not match. The rasters will be resampled to align.")
    TS_TA <- terra::resample(TS_TA, FVC)
  }

  # Ensure FVC values are in the range [0, 1]
  FVC[FVC > 1] <- 1
  FVC[FVC < 0] <- 0

  # Step 2: Convert rasters to vectors
  values_FVC <- terra::values(FVC)
  values_TS_TA <- terra::values(TS_TA)

  # Step 3: Calculate wet and dry edges
  cut_fvc <- cut(values_FVC, breaks = n_intervals)
  R1 <- data.frame()
  ligne <- 1

  for (i in 1:n_intervals) {

     idx <- which(cut_fvc == levels(cut_fvc)[i])
    table1 <- as.data.frame(table(values_TS_TA[idx])) %>%
      dplyr::rename(TS_TA = Var1)
    table1$TS_TA <- as.numeric(levels(table1$TS_TA))
    table1 <- na.omit(table1)

    pourcentages_df <- data.frame(Pourcentage = seq_along(table1$TS_TA) / length(table1$TS_TA))
    options(pillar.sigfig = 6)
    tab <- dplyr::bind_cols(table1, pourcentages_df)

    mean_lower <- tab %>%
      dplyr::filter(tab$Pourcentage <= percentile) %>%
      dplyr::summarise(mean_lower = weighted.mean(TS_TA, Freq, na.rm = TRUE))


    mean_upper <- tab %>%
      dplyr::filter(tab$Pourcentage >= (1 - percentile)) %>%
      dplyr::summarise(mean_upper = weighted.mean(TS_TA, Freq, na.rm = TRUE))


    R1[ligne, "Interval"] <- i
    R1[ligne, "Ts_wet"] <- mean_lower
    R1[ligne, "Ts_dry"] <- mean_upper

    ligne <- ligne + 1
  }

  format(round(R1, 4), nsmall = 3)
  tab_wet_dry_fvc <- R1 %>%
    dplyr::mutate(FVC = seq(0.025, 0.975, length.out = n_intervals))

  # Step 4: Deletion of the values from the first 2 rows of the table tab_wet_dry_fvc when FVC is close to 0 (no vegetation)
  tab_wet_dry_fvc[1,c(2,3)]<-NA
  tab_wet_dry_fvc[2,c(2,3)]<-NA
  tab_wet_dry_fvc

  # Step 5: Fit regression models for wet and dry edges using stats::lm
  reg_wet <- stats::lm(Ts_wet ~ FVC, data = tab_wet_dry_fvc, na.action = stats::na.exclude)
  reg_dry <- stats::lm(Ts_dry ~ FVC, data = tab_wet_dry_fvc, na.action = stats::na.exclude)

  # Extract coefficients
  a_wet <- stats::coef(reg_wet)[2]
  b_wet <- stats::coef(reg_wet)[1]
  a_dry <- stats::coef(reg_dry)[2]
  b_dry <- stats::coef(reg_dry)[1]

  # Step 6: Calculate the EF raster

 EF<-(((a_dry * FVC) + b_dry)-TS_TA)/(((a_dry * FVC) + b_dry)-((a_wet * FVC) + b_wet))



  # Clip EF values to [0, 1]
  EF[EF > 1] <- 1
  EF[EF < 0] <- 0

  # Step 7: Save and return the EF raster
  names(EF) <- "EF"
  terra::varnames(EF) <- "EF"
  terra::writeRaster(EF, output_path, overwrite = TRUE)

  # Plot the result

  terra::plot(EF,main = "EF (Evaporative Fraction)")

  return(EF)
}



