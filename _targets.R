# Created by use_targets().

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)

# Set target options:
tar_option_set(
  packages = c("tidyverse"),
  error = "continue"
)

# Run the R scripts with custom functions:
tar_source(files = c(
  "1_inventory.R",
  "2_download.R")
)

# The list of targets/steps
config_targets <- list(
  
  # General config ----------------------------------------------------------
  
  # Grab configuration information for the workflow run (config.yml)
  tar_target(
    name = p0_workflow_config,
    # The config package does not like to be used with library()
    command = config::get(config = "admin_update")
  ),
  
  
  # WQP config --------------------------------------------------------------
  
  # Things that often used to be YAMLs, and which probably should be again in 
  # the future
  
  # Date range of interest
  tar_target(
    name = p0_wq_dates,
    command = list(
      start_date = "1970-01-01",
      end_date = Sys.Date()
    )
  ),
  
  # Define which parameter groups (and CharacteristicNames) to return from WQP. 
  # Different options for parameter groups are represented in the first level of 
  # 1_inventory/cfg/wqp_codes.yml. The yml file can be edited to 
  # omit characteristic names or include others, to change top-level parameter names,
  # or to customize parameter groupings. 
  tar_target(
    name = p0_param_groups_select,
    command = c("chlorophyll", "doc", "sdd")
  ),
  
  
  # WQP inventory -----------------------------------------------------------
  
  # Specify arguments to WQP queries
  # see https://www.waterqualitydata.us/webservices_documentation for more information 
  tar_target(
    name = p0_wqp_args,
    command = list(sampleMedia = c("Water", "water"),
                   siteType = c("Lake, Reservoir, Impoundment",
                                "Stream",
                                "Estuary"),
                   # Return sites with at least one data record
                   minresults = 1, 
                   startDateLo = p0_wq_dates$start_date,
                   startDateHi = p0_wq_dates$end_date)),
  
  
  # Google Drive path setup -------------------------------------------------
  
  # Google Drive paths for outputs in this pipeline
  tar_target(
    name = p0_general_output_path,
    command = paste0(p0_workflow_config$drive_project_folder,
                     "general/")
  ),
  
  tar_target(
    name = p0_chl_output_path,
    command = paste0(p0_workflow_config$drive_project_folder,
                     "chlorophyll/")
  ),
  
  tar_target(
    name = p0_doc_output_path,
    command = paste0(p0_workflow_config$drive_project_folder,
                     "doc/")
  ), 
  
  tar_target(
    name = p0_sdd_output_path,
    command = paste0(p0_workflow_config$drive_project_folder,
                     "sdd/")
  )
)


# Full targets list
c(config_targets, p1_targets_list, p2_targets_list)

