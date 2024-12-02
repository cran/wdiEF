

# Example usage of functions from the wdiEF package

# Load the package
library(wdiEF)

FVC_path <- system.file("extdata", "FVC_reduced.tif", package = "wdiEF")
TS_TA_path <- system.file("extdata", "TS_TA_reduced.tif", package = "wdiEF")

cat("FVC Path: ", FVC_path, "\n")
cat("TS_TA Path: ", TS_TA_path, "\n")

print(FVC_path)

if (!file.exists(FVC_path)) {
  stop("The file FVC_reduced.tif was not found.")
}
if (!file.exists(TS_TA_path)) {
  stop("The file TS_TA_reduced.tif was not found.")
}

# Load the rasters
library(terra)
FVC <- rast(FVC_path)
TS_TA <- rast(TS_TA_path)

# Define output paths for temporary files
output_path_wdi <- "path_to_output_WDI.tif"
output_path_ef <- "path_to_output_EF.tif"

# Call the function to calculate WDI
calculate_WDI(
  FVC_path = FVC,
  TS_TA_path = TS_TA,
  output_path = output_path_wdi,
  n_intervals = 20,
  percentile = 0.01
)

# Verification of the generated WDI file
if (!file.exists(output_path_wdi)) stop("WDI output file not created")
message("WDI calculation completed successfully.")

# Recharger les rasters avant le calcul de EF
FVC <- rast(FVC_path)
TS_TA <- rast(TS_TA_path)

# Call the function to calculate EF
calculate_EF(
  FVC_path = FVC,
  TS_TA_path = TS_TA,
  output_path = output_path_ef,
  n_intervals = 20,
  percentile = 0.01
)

# Verification of the generated EF file
if (!file.exists(output_path_ef)) stop("EF output file not created")
message("EF calculation completed successfully.")
