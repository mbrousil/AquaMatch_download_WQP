# Source the functions that will be used to build the targets in p1_targets_list
tar_source("1_inventory/src/")


p1_targets_list <- list(
  
  # Get parameter definitions -----------------------------------------------
  
  # Track yml file containing common parameter groups and WQP characteristic names
  # If {targets} detects a change in the yml file, it will re-build all downstream
  # targets that depend on p1_wqp_params_yml assuming that p0_param_groups_select
  # indicates that any new parameters should be included in the pipeline.
  tar_file_read(
    name = p1_wqp_params,
    command = "1_inventory/cfg/wqp_codes.yml",
    read = read_yaml(!!.x),
    packages = "yaml"
  ),
  
  # Break out chlorophyll param data
  tar_target(
    name = p1_wqp_params_chl,
    command = p1_wqp_params["chlorophyll"]
  ),
  
  # Colored dissolved organic matter
  tar_target(
    name = p1_wqp_params_cdom,
    command = p1_wqp_params["cdom"]
  ),
  
  # Dissolved organic carbon
  tar_target(
    name = p1_wqp_params_doc,
    command = p1_wqp_params["doc"]
  ),
  
  # Dissolved organic matter
  tar_target(
    name = p1_wqp_params_tss,
    command = p1_wqp_params["tss"]
  ),
  
  # Secchi disk depth
  tar_target(
    name = p1_wqp_params_sdd,
    command = p1_wqp_params["sdd"]
  ),
  
  # Colored dissolved organic matter
  tar_target(
    name = p1_wqp_params_cdom,
    command = p1_wqp_params["cdom"]
  ),
  
  
  # Export parameter yaml info ----------------------------------------------
  
  # Use {googledrive} to upload each parameter's yaml data. It will be needed in
  # the second pipeline. Then return a file containing the link as text to be 
  # accessed outside of this pipeline
  
  # Chlorophyll
  tar_target(
    name = p1_wqp_params_file_chl,
    command = export_single_file(target = p1_wqp_params_chl,
                                 drive_path = p0_chl_output_path,
                                 stable = p0_workflow_config$chl_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp),
    packages = c("tidyverse", "googledrive"),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # CDOM
  tar_target(
    name = p1_wqp_params_file_cdom,
    command = export_single_file(target = p1_wqp_params_cdom,
                                 drive_path = p0_cdom_output_path,
                                 stable = p0_workflow_config$cdom_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp),
    packages = c("tidyverse", "googledrive"),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # DOC
  tar_target(
    name = p1_wqp_params_file_doc,
    command = export_single_file(target = p1_wqp_params_doc,
                                 drive_path = p0_doc_output_path,
                                 stable = p0_workflow_config$doc_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp),
    packages = c("tidyverse", "googledrive"),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # TSS
  tar_target(
    name = p1_wqp_params_file_tss,
    command = export_single_file(target = p1_wqp_params_tss,
                                 drive_path = p0_tss_output_path,
                                 stable = p0_workflow_config$tss_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp),
    packages = c("tidyverse", "googledrive"),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # SDD
  tar_target(
    name = p1_wqp_params_file_sdd,
    command = export_single_file(target = p1_wqp_params_sdd,
                                 drive_path = p0_sdd_output_path,
                                 stable = p0_workflow_config$sdd_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp),
    packages = c("tidyverse", "googledrive"),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # CDOM
  tar_target(
    name = p1_wqp_params_file_cdom,
    command = export_single_file(target = p1_wqp_params_cdom,
                                 drive_path = p0_cdom_output_path,
                                 stable = p0_workflow_config$chl_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp),
    packages = c("tidyverse", "googledrive"),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  
  # Parameter-characteristic crosswalks -------------------------------------
  
  # Format tables that indicate how various WQP characteristic names map onto 
  # each parameter name
  
  # Chlorophyll
  tar_target(
    name = p1_char_names_crosswalk_chl,
    command = crosswalk_characteristics(p1_wqp_params_chl)
  ),
  
  # CDOM
  tar_target(
    name = p1_char_names_crosswalk_cdom,
    command = crosswalk_characteristics(p1_wqp_params_cdom)
  ),
  
  # DOC
  tar_target(
    name = p1_char_names_crosswalk_doc,
    command = crosswalk_characteristics(p1_wqp_params_doc)
  ),
  
  # TSS
  tar_target(
    name = p1_char_names_crosswalk_tss,
    command = crosswalk_characteristics(p1_wqp_params_tss)
  ),
  
  # SDD
  tar_target(
    name = p1_char_names_crosswalk_sdd,
    command = crosswalk_characteristics(p1_wqp_params_sdd)
  ),
  
  # CDOM
  tar_target(
    name = p1_char_names_crosswalk_cdom,
    command = crosswalk_characteristics(p1_wqp_params_cdom)
  ),
  
  
  # Use {googledrive} to upload the crosswalk data, which will be needed in
  # the second pipeline. Then return a file containing the link as text to be 
  # used outside of this pipeline.
  
  # NOTE: A common issue when updating the pipeline with a new parameter to
  # download is forgetting to invalidate p0_workflow_config. This will cause
  # errors with export_single_file(stable = ...) because the old version of
  # p0_workflow_config doesn't contain info about the new parameter.
  
  # Chlorophyll
  tar_target(
    name = p1_char_names_crosswalk_chl_file,
    command = export_single_file(target = p1_char_names_crosswalk_chl,
                                 drive_path = p0_chl_output_path,
                                 stable = p0_workflow_config$chl_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp),
    packages = c("tidyverse", "googledrive"),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # CDOM
  tar_target(
    name = p1_char_names_crosswalk_cdom_file,
    command = export_single_file(target = p1_char_names_crosswalk_cdom,
                                 drive_path = p0_cdom_output_path,
                                 stable = p0_workflow_config$cdom_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp),
    packages = c("tidyverse", "googledrive"),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # DOC
  tar_target(
    name = p1_char_names_crosswalk_doc_file,
    command = export_single_file(target = p1_char_names_crosswalk_doc,
                                 drive_path = p0_doc_output_path,
                                 stable = p0_workflow_config$doc_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp),
    packages = c("tidyverse", "googledrive"),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # TSS
  tar_target(
    name = p1_char_names_crosswalk_tss_file,
    command = export_single_file(target = p1_char_names_crosswalk_tss,
                                 drive_path = p0_tss_output_path,
                                 stable = p0_workflow_config$tss_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp),
    packages = c("tidyverse", "googledrive"),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # SDD
  tar_target(
    name = p1_char_names_crosswalk_sdd_file,
    command = export_single_file(target = p1_char_names_crosswalk_sdd,
                                 drive_path = p0_sdd_output_path,
                                 stable = p0_workflow_config$sdd_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp),
    packages = c("tidyverse", "googledrive"),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # CDOM
  tar_target(
    name = p1_char_names_crosswalk_cdom_file,
    command = export_single_file(target = p1_char_names_crosswalk_cdom,
                                 drive_path = p0_cdom_output_path,
                                 stable = p0_workflow_config$cdom_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp),
    packages = c("tidyverse", "googledrive"),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  
  # Get a vector of WQP characteristic names to match parameter groups of interest
  
  # Chlorophyll
  tar_target(
    name = p1_char_names_chl,
    command = filter_characteristics(p1_char_names_crosswalk_chl,
                                     p0_param_groups_select),
    packages = c("tidyverse", "xml2")
  ),
  
  # CDOM
  tar_target(
    name = p1_char_names_cdom,
    command = filter_characteristics(p1_char_names_crosswalk_cdom,
                                     p0_param_groups_select),
    packages = c("tidyverse", "xml2")
  ),
  
  # DOC
  tar_target(
    name = p1_char_names_doc,
    command = filter_characteristics(p1_char_names_crosswalk_doc,
                                     p0_param_groups_select),
    packages = c("tidyverse", "xml2")
  ),
  
  # TSS
  tar_target(
    name = p1_char_names_tss,
    command = filter_characteristics(p1_char_names_crosswalk_tss,
                                     p0_param_groups_select),
    packages = c("tidyverse", "xml2")
  ),
  
  # SDD
  tar_target(
    name = p1_char_names_sdd,
    command = filter_characteristics(p1_char_names_crosswalk_sdd,
                                     p0_param_groups_select),
    packages = c("tidyverse", "xml2")
  ),
  
  # CDOM
  tar_target(
    name = p1_char_names_cdom,
    command = filter_characteristics(p1_char_names_crosswalk_cdom,
                                     p0_param_groups_select),
    packages = c("tidyverse", "xml2")
  ),
  
  
  # Save output file(s) containing WQP characteristic names that are similar to
  # the parameter groups of interest. This allows users to examine the list to
  # see if there are other parameters that they may wish to add to the yaml file
  # for each parameter, stored in p1_wqp_params.
  tar_file(
    name = p1_similar_char_names_chl_txt,
    command = find_similar_characteristics(p1_char_names_chl,
                                           "chlorophyll",
                                           "1_inventory/out"),
    packages = c("tidyverse", "xml2")
  ),
  
  tar_file(
    name = p1_similar_char_names_cdom_txt,
    command = find_similar_characteristics(p1_char_names_cdom,
                                           "cdom",
                                           "1_inventory/out"),
    packages = c("tidyverse", "xml2")
  ),
  
  tar_file(
    name = p1_similar_char_names_doc_txt,
    command = find_similar_characteristics(p1_char_names_doc,
                                           "doc",
                                           "1_inventory/out"),
    packages = c("tidyverse", "xml2")
  ),
  
  tar_file(
    name = p1_similar_char_names_tss_txt,
    command = find_similar_characteristics(p1_char_names_tss,
                                           "tss",
                                           "1_inventory/out"),
    packages = c("tidyverse", "xml2")
  ),
  
  tar_file(
    name = p1_similar_char_names_sdd_txt,
    command = find_similar_characteristics(p1_char_names_sdd,
                                           "sdd",
                                           "1_inventory/out"),
    packages = c("tidyverse", "xml2")
  ),
  
  tar_file(
    name = p1_similar_char_names_cdom_txt,
    command = find_similar_characteristics(p1_char_names_cdom,
                                           "cdom",
                                           "1_inventory/out"),
    packages = c("tidyverse", "xml2")
  ),
  
  
  # Define spatial AOI and grid ---------------------------------------------
  
  tar_target(
    name = p1_AOI_sf,
    command = states(),
    packages = c("tidyverse", "tigris")
  ),
  
  # Create a big grid of boxes to set up chunked data queries.
  # The resulting grid, which covers the globe, allows for queries
  # outside of CONUS, including AK, HI, and US territories. 
  tar_target(
    name = p1_global_grid,
    command = create_global_grid(),
    packages = c("tidyverse", "sf")
  ),
  
  # Use {googledrive} to upload the global grid data, which will be needed in
  # the second pipeline. Then return a file containing the link as text to be 
  # used outside of this pipeline
  tar_target(
    name = p1_global_grid_file,
    command = export_single_file(target = p1_global_grid,
                                 drive_path = p0_general_output_path,
                                 stable = p0_workflow_config$general_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp),
    packages = c("tidyverse", "googledrive"),
    error = "stop"
  ),
  
  # Use spatial subsetting to find boxes that overlap the area of interest
  # These boxes will be used to query the WQP.
  tar_target(
    name = p1_global_grid_aoi,
    command = subset_grids_to_aoi(p1_global_grid, p1_AOI_sf),
    packages = c("tidyverse", "units")
  ),
  
  
  # Create WQP inventory ----------------------------------------------------
  
  # Inventory data available from the WQP within each of the boxes that overlap
  # the area of interest. To prevent timeout issues that result from large data 
  # requests, use {targets} dynamic branching capabilities to map the function 
  # inventory_wqp() over each grid within p1_global_grid_aoi. {targets} will then
  # combine all of the grid-scale inventories into one table. See comments above
  # target p2_wqp_data_aoi (in 2_download.R) regarding the use of error = 'continue'.
  
  # Chlorophyll
  tar_target(
    name = p1_wqp_inventory_chl,
    command = {
      # inventory_wqp() requires grid and char_names as inputs, but users can 
      # also pass additional arguments to WQP, e.g. sampleMedia or siteType, using 
      # wqp_args. Below, wqp_args is defined in _targets.R. See documentation
      # in 1_fetch/src/get_wqp_inventory.R for further details.
      inventory_wqp(grid = p1_global_grid_aoi,
                    char_names = p1_char_names_chl,
                    wqp_args = p0_wqp_args)
    },
    pattern = cross(p1_global_grid_aoi, p1_char_names_chl),
    error = "continue",
    packages = c("tidyverse", "retry", "sf", "dataRetrieval", "units")
  ),
  
  
  # CDOM
  tar_target(
    name = p1_wqp_inventory_cdom,
    command = {
      inventory_wqp(grid = p1_global_grid_aoi,
                    char_names = p1_char_names_cdom,
                    wqp_args = p0_wqp_args)
    },
    pattern = cross(p1_global_grid_aoi, p1_char_names_cdom),
    error = "continue",
    packages = c("tidyverse", "retry", "sf", "dataRetrieval", "units")
  ),
  
  # DOC
  tar_target(
    name = p1_wqp_inventory_doc,
    command = {
      inventory_wqp(grid = p1_global_grid_aoi,
                    char_names = p1_char_names_doc,
                    wqp_args = p0_wqp_args)
    },
    pattern = cross(p1_global_grid_aoi, p1_char_names_doc),
    error = "continue",
    packages = c("tidyverse", "retry", "sf", "dataRetrieval", "units")
  ),
  
  # TSS
  tar_target(
    name = p1_wqp_inventory_tss,
    command = {
      inventory_wqp(grid = p1_global_grid_aoi,
                    char_names = p1_char_names_tss,
                    wqp_args = p0_wqp_args)
    },
    pattern = cross(p1_global_grid_aoi, p1_char_names_tss),
    error = "continue",
    packages = c("tidyverse", "retry", "sf", "dataRetrieval", "units")
  ),
  
  # SDD
  tar_target(
    name = p1_wqp_inventory_sdd,
    command = {
      inventory_wqp(grid = p1_global_grid_aoi,
                    char_names = p1_char_names_sdd,
                    wqp_args = p0_wqp_args)
    },
    pattern = cross(p1_global_grid_aoi, p1_char_names_sdd),
    error = "continue",
    packages = c("tidyverse", "retry", "sf", "dataRetrieval", "units")
  ),
  
  # CDOM
  tar_target(
    name = p1_wqp_inventory_cdom,
    command = {
      inventory_wqp(grid = p1_global_grid_aoi,
                    char_names = p1_char_names_cdom,
                    wqp_args = p0_wqp_args)
    },
    pattern = cross(p1_global_grid_aoi, p1_char_names_cdom),
    error = "continue",
    packages = c("tidyverse", "retry", "sf", "dataRetrieval", "units")
  ),
  
  
  # Subset the WQP inventory to only retain sites within the area of interest
  
  # Chlorophyll
  tar_target(
    name = p1_wqp_inventory_aoi_chl,
    command = subset_inventory(p1_wqp_inventory_chl, p1_AOI_sf)
  ),
  
  # CDOM
  tar_target(
    name = p1_wqp_inventory_aoi_cdom,
    command = subset_inventory(p1_wqp_inventory_cdom, p1_AOI_sf)
  ),
  
  # DOC
  tar_target(
    name = p1_wqp_inventory_aoi_doc,
    command = subset_inventory(p1_wqp_inventory_doc, p1_AOI_sf)
  ),
  
  # TSS
  tar_target(
    name = p1_wqp_inventory_aoi_tss,
    command = subset_inventory(p1_wqp_inventory_tss, p1_AOI_sf)
  ),
  
  # SDD
  tar_target(
    name = p1_wqp_inventory_aoi_sdd,
    command = subset_inventory(p1_wqp_inventory_sdd, p1_AOI_sf)
  ),
  
  # CDOM
  tar_target(
    name = p1_wqp_inventory_aoi_cdom,
    command = subset_inventory(p1_wqp_inventory_cdom, p1_AOI_sf)
  ),
  
  
  # Export inventory --------------------------------------------------------
  
  # Use {googledrive} to upload the inventory data, which will be needed in
  # the second pipeline
  
  # Chlorophyll
  tar_target(
    name = p1_wqp_inventory_aoi_chl_file,
    command = export_single_file(target = p1_wqp_inventory_aoi_chl,
                                 drive_path = p0_chl_output_path,
                                 stable = p0_workflow_config$chl_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp),
    packages = c("tidyverse", "googledrive"),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # CDOM
  tar_target(
    name = p1_wqp_inventory_aoi_cdom_file,
    command = export_single_file(target = p1_wqp_inventory_aoi_cdom,
                                 drive_path = p0_cdom_output_path,
                                 stable = p0_workflow_config$cdom_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp),
    packages = c("tidyverse", "googledrive"),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # DOC
  tar_target(
    name = p1_wqp_inventory_aoi_doc_file,
    command = export_single_file(target = p1_wqp_inventory_aoi_doc,
                                 drive_path = p0_doc_output_path,
                                 stable = p0_workflow_config$doc_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp),
    packages = c("tidyverse", "googledrive"),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # TSS
  tar_target(
    name = p1_wqp_inventory_aoi_tss_file,
    command = export_single_file(target = p1_wqp_inventory_aoi_tss,
                                 drive_path = p0_tss_output_path,
                                 stable = p0_workflow_config$tss_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp),
    packages = c("tidyverse", "googledrive"),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # SDD
  tar_target(
    name = p1_wqp_inventory_aoi_sdd_file,
    command = export_single_file(target = p1_wqp_inventory_aoi_sdd,
                                 drive_path = p0_sdd_output_path,
                                 stable = p0_workflow_config$sdd_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp),
    packages = c("tidyverse", "googledrive"),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # CDOM
  tar_target(
    name = p1_wqp_inventory_aoi_cdom_file,
    command = export_single_file(target = p1_wqp_inventory_aoi_cdom,
                                 drive_path = p0_cdom_output_path,
                                 stable = p0_workflow_config$cdom_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp),
    packages = c("tidyverse", "googledrive"),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # Summarize the data that would come back from the WQP
  
  # Chlorophyll
  tar_file(
    name = p1_wqp_inventory_chl_summary_csv,
    command = summarize_wqp_inventory(p1_wqp_inventory_aoi_chl,
                                      "1_inventory/log/chl_summary_wqp_inventory.csv")
  ),
  
  # CDOM
  tar_file(
    name = p1_wqp_inventory_cdom_summary_csv,
    command = summarize_wqp_inventory(p1_wqp_inventory_aoi_cdom,
                                      "1_inventory/log/cdom_summary_wqp_inventory.csv")
  ),
  
  # DOC
  tar_file(
    name = p1_wqp_inventory_doc_summary_csv,
    command = summarize_wqp_inventory(p1_wqp_inventory_aoi_doc,
                                      "1_inventory/log/doc_summary_wqp_inventory.csv")
  ),
  
  # TSS
  tar_file(
    name = p1_wqp_inventory_tss_summary_csv,
    command = summarize_wqp_inventory(p1_wqp_inventory_aoi_tss,
                                      "1_inventory/log/tss_summary_wqp_inventory.csv")
  ),
  
  # SDD
  tar_file(
    name = p1_wqp_inventory_sdd_summary_csv,
    command = summarize_wqp_inventory(p1_wqp_inventory_aoi_sdd,
                                      "1_inventory/log/sdd_summary_wqp_inventory.csv")
  ),
  
  # CDOM
  tar_file(
    name = p1_wqp_inventory_cdom_summary_csv,
    command = summarize_wqp_inventory(p1_wqp_inventory_aoi_cdom,
                                      "1_inventory/log/cdom_summary_wqp_inventory.csv")
  )
)
