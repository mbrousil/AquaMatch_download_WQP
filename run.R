#!/usr/bin/env Rscript

# Package handling --------------------------------------------------------

# List of packages required for this pipeline
required_pkgs <- c(
  "dataRetrieval",
  "feather",
  "googledrive",
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
library(tidyverse)
library(googledrive)
library(targets)


# Directory handling ------------------------------------------------------

# List of directories to check for and create if they don't exist
dir_list <- c(
  "out",
  "1_inventory/log/",
  "1_inventory/out/",
  "2_download/log/",
  "2_download/out/"
)

# Check for the directories above and create if they don't exist
walk(.x = dir_list,
     .f = ~ {
       if (!dir.exists(.x)) {dir.create(.x, recursive = TRUE)}
     })


# Google Drive auth -------------------------------------------------------

# Confirm Google Drive is authorized locally
drive_auth()
# Select existing account (change if starting from scratch)
2


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
