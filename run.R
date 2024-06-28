#!/usr/bin/env Rscript

# Please review README.md prior to running the pipeline! It provides important
# instructions for proper configuration.

# Package handling --------------------------------------------------------

# List of packages required for this pipeline
required_pkgs <- c(
  "config",
  "dataRetrieval",
  "feather",
  "googledrive",
  "lutz",
  "MESS",
  "retry",
  "sf",
  "targets", 
  "tarchetypes",
  "tidyverse",
  "tigris",
  "units",
  "xml2",
  "yaml")

# Helper function to install all necessary packages
package_installer <- function(x) {
  if (x %in% installed.packages()) {
    print(paste0("{", x ,"} package is already installed."))
  } else {
    install.packages(x)
    print(paste0("{", x ,"} package has been installed."))
  }
}

# map function using base lapply
lapply(required_pkgs, package_installer)

# Load packages for use below
library(googledrive)
library(targets)

# Prior to running the pipeline, confirm that the config.yml settings are correct
# and that you have set line 28 in `_targets.R` to the appropriate config setting.

# Google Drive auth -------------------------------------------------------

# Confirm Google Drive is authorized locally
drive_auth()


# Run pipeline ------------------------------------------------------------

# This is a helper script to run the pipeline.
{
  tar_make()
  
  # Create a network diagram of the workflow, with a completion timestamp
  temp_vis <- tar_visnetwork()
  
  temp_vis$x$main$text <- paste0("Last completed: ", Sys.time())
  
  htmltools::save_html(html = temp_vis,
                       file = "out/current_visnetwork.html")
}
