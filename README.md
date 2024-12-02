# wdiEF Package

The **wdiEF** package provides tools to calculate the Water Deficit Index
(WDI) and the Evaporative Fraction (EF) from raster data. It utilizes fractional vegetation cover (FVC) and
surface-air temperature difference (TS-TA) to generate the WDI or EF raster.

## Installation

You can install the development version of **wdiEF** directly from your
local folder:

### Requirements

-   The input rasters (`TS` and `TA`) must have the same unit of
    measurement (Kelvin preferably) to ensure accurate calculations of `TS-TA` and 
    the Water Deficit Index (WDI) or the Evaporative Fraction (EF).

-   The input rasters (`FVC` and `TS-TA`) must:

    -   Have the same Coordinate Reference System (CRS).
    -   Cover the same geographic extent.

-   If these conditions are not met, the function attempt to align the
    rasters automatically (with warnings).

### Dependencies

The `wdiEF` package automatically manages the following dependencies: -
`terra` for raster manipulation. - `dplyr` for data manipulation. -
`stats` for statistical calculations.

You do not need to load these packages manually; they are handled
internally by `wdiEF`

## Examples Usage of the `wdiEF` Package

To use the `wdiEF` package, start by loading the necessary library in R.

- Define the paths to the input files (FVC and TS-TA rasters) and
  the output path for the calculated WDI raster.

    # Load the necessary package
    library(wdiEF)

    # Input raster paths
    FVC_path <- "path/to/FVC.tif"
    TS_TA_path <- "path/to/TS_TA.tif"

    # Output raster path
    output_path <- "path/to/WDI.tif"

    # Calculate WDI
    calculate_WDI(
      FVC_path = FVC_path,
      TS_TA_path = TS_TA_path,
      output_path = output_path,
      n_intervals = 20,
      percentile = 0.01
    )

    # Check the output
    WDI <- terra::rast(output_path)
    plot(WDI)
    
    
 - Define the paths to the input files (FVC and TS-TA rasters) and
  the output path for the calculated EF raster.

    # Load the necessary package
    library(wdiEF)

    # Input raster paths
    FVC_path <- "path/to/FVC.tif"
    TS_TA_path <- "path/to/TS_TA.tif"

    # Output raster path
    output_path <- "path/to/EF.tif"

    # Calculate EF
    calculate_EF(
      FVC_path = FVC_path,
      TS_TA_path = TS_TA_path,
      output_path = output_path,
      n_intervals = 20,
      percentile = 0.01
    )

    # Check the output
    EF <- terra::rast(output_path)
    plot(EF)   
    
