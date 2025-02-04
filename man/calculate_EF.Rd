% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calculate_EF.R
\name{calculate_EF}
\alias{calculate_EF}
\title{Calculate the Evaporative Fraction (EF)}
\usage{
calculate_EF(
  FVC_path,
  TS_TA_path,
  output_path,
  n_intervals = 20,
  percentile = 0.01
)
}
\arguments{
\item{FVC_path}{Character. File path to the FVC raster.Must have the same
CRS and extent as the TS-TA raster.}

\item{TS_TA_path}{Character. File path to the raster of TS-TA (surface-air temperature difference).
TS and TA must have the same unit of measurement (Kelvin preferably).}

\item{output_path}{Character. File path where the EF raster will be saved.}

\item{n_intervals}{Integer. Number of intervals for splitting FVC values
(default: 20).}

\item{percentile}{Numeric. Percentage used for identifying wet and dry edges
(default: 0.01).}
}
\value{
A raster object representing the Evaporative Fraction (EF).
}
\description{
This function calculates the EF from two rasters: fractional vegetation cover (FVC)
and the surface-air temperature difference (TS-TA). It saves the resulting
EF raster to the specified output path.
}
\details{
\itemize{
\item The input rasters (\code{FVC} and \code{TS-TA}) must have the same CRS (Coordinate Reference System) and extent.
\item If they differ, the function will attempt to reproject and resample the rasters automatically.
}
}
\examples{
# Paths to example data included in the package
library(terra)

FVC_raster <- rast(system.file("extdata", "FVC_reduced.tif", package = "wdiEF"))
TS_TA_raster <- rast(system.file("extdata", "TS_TA_reduced.tif", package = "wdiEF"))

# Output path (temporary file for example purposes)
output_path <- tempfile(fileext = ".tif")

# Run the function
calculate_EF(
  FVC_path = FVC_raster,
  TS_TA_path = TS_TA_raster,
  output_path = output_path,
  n_intervals = 20,
  percentile = 0.01
)

# Print the output path
print(output_path)

}
