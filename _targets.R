# Created by use_targets().

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)

# Set target options:
tar_option_set(
  packages = c("tidyverse", "sf"),
  error = "continue"
)

# Run the R scripts with custom functions:
tar_source(files = c(
  "1_inventory.R",
  "2_download.R")
)

# Source the functions that will be used to build the targets in config_targets
tar_source("src/")

# The list of targets/steps
config_targets <- list(
  
  # General config ----------------------------------------------------------
  
  # Grab configuration information for the workflow run (config.yml)
  tar_target(
    name = p0_workflow_config,
    # The config package does not like to be used with library()
    command = config::get(config = "admin_update")
  ),
  
  # A standardized system date from the start of the workflow to ensure that
  # no steps accidentally use different dates based on when a specific target
  # is reached during computation
  tar_target(
    name = p0_date_stamp,
    command = Sys.Date()
  ),
  
  
  # WQP config --------------------------------------------------------------
  
  # Things that often used to be YAMLs, and which probably should be again in 
  # the future
  
  # Date range of interest
  tar_target(
    name = p0_wq_dates,
    command = list(
      start_date = "1970-01-01",
      end_date = p0_date_stamp
    )
  ),
  
  # Define which parameter groups (and CharacteristicNames) to return from WQP. 
  # Different options for parameter groups are represented in the first level of 
  # 1_inventory/cfg/wqp_codes.yml. The yml file can be edited to 
  # omit characteristic names or include others, to change top-level parameter names,
  # or to customize parameter groupings. 
  tar_target(
    name = p0_param_groups_select,
    command = c("chlorophyll", "doc", "sdd", "tss", "cdom")
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
  
  # Check for Drive folder paths and create if necessary 
  
  # Check for Drive parent folder
  tar_target(
    name = p0_check_drive_parent_folder,
    command = {
      tryCatch({
        drive_auth(p0_workflow_config$google_email)
        drive_ls(p0_workflow_config$drive_project_folder)
      }, error = function(e) {
        drive_mkdir(str_sub(p0_workflow_config$drive_project_folder, 1, -2))  
      })
    },
    packages = "googledrive",
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # list Drive folder paths required in parent folder
  tar_target(
    name = p0_drive_folders,
    command = c(p0_param_groups_select, "general")
  ),
  
  # Check for each of the Drive folder paths
  tar_target(
    name = p0_check_drive_paths,
    command = check_drive_download_paths(
      folder = p0_drive_folders,
      google_email = p0_workflow_config$google_email,
      project_folder = p0_workflow_config$drive_project_folder
    ),
    pattern = map(p0_drive_folders),
    packages = "googledrive",
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # Store Google Drive paths as targets in this pipeline
  tar_target(
    name = p0_general_output_path,
    command = {
      p0_check_drive_paths
      paste0(p0_workflow_config$drive_project_folder,
             "general/")
    }
  ),
  
  tar_target(
    name = p0_chl_output_path,
    command = {
      p0_check_drive_paths
      paste0(p0_workflow_config$drive_project_folder,
             "chlorophyll/")
      
    }
  ),
  
  tar_target(
    name = p0_cdom_output_path,
    command = {
      p0_check_drive_paths
      paste0(p0_workflow_config$drive_project_folder,
             "cdom/")
      
    }
  ),
  
  tar_target(
    name = p0_doc_output_path,
    command = {
      p0_check_drive_paths
      paste0(p0_workflow_config$drive_project_folder,
             "doc/")
    }
  ), 
  
  tar_target(
    name = p0_tss_output_path,
    command = {
      p0_check_drive_paths
      paste0(p0_workflow_config$drive_project_folder,
             "tss/")
    }
  ), 
  
  tar_target(
    name = p0_sdd_output_path,
    command = {
      p0_check_drive_paths
      paste0(p0_workflow_config$drive_project_folder,
             "sdd/")
    }
  )
)


# Full targets list
c(config_targets, p1_targets_list, p2_targets_list)

