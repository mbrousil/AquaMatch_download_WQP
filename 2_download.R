# Source the functions that will be used to build the targets in p2_targets_list
tar_source("2_download/src/")

p2_targets_list <- list(
  
  # Count number of records per site ----------------------------------------
  
  # Pull site IDs and total number of records for each site from the WQP inventory
  
  # Chlorophyll
  tar_target(
    name = p2_site_counts_chl,
    command = p1_wqp_inventory_aoi_chl %>%
      # Hold onto location info, grid_id, characteristic, and provider data
      # and use them for grouping
      group_by(MonitoringLocationIdentifier, lon, lat, datum, grid_id,
               CharacteristicName, ProviderName) %>%
      # Count the number of rows per group
      summarize(results_count = sum(resultCount, na.rm = TRUE),
                .groups = "drop") %>%
      # Add the overarching parameter names to the dataset
      left_join(x = .,
                y = p1_wqp_params_chl %>%
                  map2_df(.x,
                          .y = names(.),
                          .f = ~{
                            tibble(CharacteristicName = .x,
                                   parameter = .y)
                          }),
                by = "CharacteristicName")
  ),
  
  # CDOM
  tar_target(
    name = p2_site_counts_cdom,
    command = p1_wqp_inventory_aoi_cdom %>%
      # Hold onto location info, grid_id, characteristic, and provider data
      # and use them for grouping
      group_by(MonitoringLocationIdentifier, lon, lat, datum, grid_id,
               CharacteristicName, ProviderName) %>%
      # Count the number of rows per group
      summarize(results_count = sum(resultCount, na.rm = TRUE),
                .groups = "drop") %>%
      # Add the overarching parameter names to the dataset
      left_join(x = .,
                y = p1_wqp_params_cdom %>%
                  map2_df(.x,
                          .y = names(.),
                          .f = ~{
                            tibble(CharacteristicName = .x,
                                   parameter = .y)
                          }),
                by = "CharacteristicName")
  ),
  
  # DOC
  tar_target(
    name = p2_site_counts_doc,
    command = p1_wqp_inventory_aoi_doc %>%
      # Hold onto location info, grid_id, characteristic, and provider data
      # and use them for grouping
      group_by(MonitoringLocationIdentifier, lon, lat, datum, grid_id,
               CharacteristicName, ProviderName) %>%
      # Count the number of rows per group
      summarize(results_count = sum(resultCount, na.rm = TRUE),
                .groups = "drop") %>%
      # Add the overarching parameter names to the dataset
      left_join(x = .,
                y = p1_wqp_params_doc %>%
                  map2_df(.x,
                          .y = names(.),
                          .f = ~{
                            tibble(CharacteristicName = .x,
                                   parameter = .y)
                          }),
                by = "CharacteristicName")
  ),
  
  # TSS
  tar_target(
    name = p2_site_counts_tss,
    command = p1_wqp_inventory_aoi_tss %>%
      # Hold onto location info, grid_id, characteristic, and provider data
      # and use them for grouping
      group_by(MonitoringLocationIdentifier, lon, lat, datum, grid_id,
               CharacteristicName, ProviderName) %>%
      # Count the number of rows per group
      summarize(results_count = sum(resultCount, na.rm = TRUE),
                .groups = "drop") %>%
      # Add the overarching parameter names to the dataset
      left_join(x = .,
                y = p1_wqp_params_tss %>%
                  map2_df(.x,
                          .y = names(.),
                          .f = ~{
                            tibble(CharacteristicName = .x,
                                   parameter = .y)
                          }),
                by = "CharacteristicName")
  ),
  
  # SDD
  tar_target(
    name = p2_site_counts_sdd,
    command = p1_wqp_inventory_aoi_sdd %>%
      # Hold onto location info, grid_id, characteristic, and provider data
      # and use them for grouping
      group_by(MonitoringLocationIdentifier, lon, lat, datum, grid_id,
               CharacteristicName, ProviderName) %>%
      # Count the number of rows per group
      summarize(results_count = sum(resultCount, na.rm = TRUE),
                .groups = "drop") %>%
      # Add the overarching parameter names to the dataset
      left_join(x = .,
                y = p1_wqp_params_sdd %>%
                  map2_df(.x,
                          .y = names(.),
                          .f = ~{
                            tibble(CharacteristicName = .x,
                                   parameter = .y)
                          }),
                by = "CharacteristicName")
  ),
  
  # CDOM
  tar_target(
    name = p2_site_counts_cdom,
    command = p1_wqp_inventory_aoi_cdom %>%
      # Hold onto location info, grid_id, characteristic, and provider data
      # and use them for grouping
      group_by(MonitoringLocationIdentifier, lon, lat, datum, grid_id,
               CharacteristicName, ProviderName) %>%
      # Count the number of rows per group
      summarize(results_count = sum(resultCount, na.rm = TRUE),
                .groups = "drop") %>%
      # Add the overarching parameter names to the dataset
      left_join(x = .,
                y = p1_wqp_params_cdom %>%
                  map2_df(.x,
                          .y = names(.),
                          .f = ~{
                            tibble(CharacteristicName = .x,
                                   parameter = .y)
                          }),
                by = "CharacteristicName")
  ),
  
  
  # Export site counts ------------------------------------------------------
  
  # Use {googledrive} to upload the site counts data, which will be needed in
  # the second pipeline.
  
  # Chlorophyll
  tar_target(
    name = p2_site_counts_chl_file,
    command = export_single_file(target = p2_site_counts_chl,
                                 drive_path = p0_chl_output_path,
                                 stable = p0_workflow_config$chl_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # CDOM
  tar_target(
    name = p2_site_counts_cdom_file,
    command = export_single_file(target = p2_site_counts_cdom,
                                 drive_path = p0_cdom_output_path,
                                 stable = p0_workflow_config$cdom_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # DOC
  tar_target(
    name = p2_site_counts_doc_file,
    command = export_single_file(target = p2_site_counts_doc,
                                 drive_path = p0_doc_output_path,
                                 stable = p0_workflow_config$doc_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # TSS
  tar_target(
    name = p2_site_counts_tss_file,
    command = export_single_file(target = p2_site_counts_tss,
                                 drive_path = p0_tss_output_path,
                                 stable = p0_workflow_config$tss_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # SDD
  tar_target(
    name = p2_site_counts_sdd_file,
    command = export_single_file(target = p2_site_counts_sdd,
                                 drive_path = p0_sdd_output_path,
                                 stable = p0_workflow_config$sdd_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # CDOM
  tar_target(
    name = p2_site_counts_cdom_file,
    command = export_single_file(target = p2_site_counts_cdom,
                                 drive_path = p0_cdom_output_path,
                                 stable = p0_workflow_config$cdom_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  
  # Create download groups --------------------------------------------------
  
  # Group the site counts separately for each parameter in the pipeline:
  # Chlorophyll
  tar_target(
    name = p2_site_counts_grouped_chl,
    command = add_download_groups(p2_site_counts_chl, 
                                  max_sites = 100,
                                  max_results = 250000) %>%
      group_by(download_grp) %>%
      tar_group(),
    iteration = "group",
    packages = c("tidyverse", "MESS")
  ),
  
  # CDOM
  tar_target(
    name = p2_site_counts_grouped_cdom,
    command = add_download_groups(p2_site_counts_cdom, 
                                  max_sites = 100,
                                  max_results = 250000) %>%
      group_by(download_grp) %>%
      tar_group(),
    iteration = "group",
    packages = c("tidyverse", "MESS")
  ),
  
  # DOC
  tar_target(
    name = p2_site_counts_grouped_doc,
    command = add_download_groups(p2_site_counts_doc, 
                                  max_sites = 100,
                                  max_results = 250000) %>%
      group_by(download_grp) %>%
      tar_group(),
    iteration = "group",
    packages = c("tidyverse", "MESS")
  ),
  
  # TSS
  tar_target(
    name = p2_site_counts_grouped_tss,
    command = add_download_groups(p2_site_counts_tss, 
                                  max_sites = 100,
                                  max_results = 250000) %>%
      group_by(download_grp) %>%
      tar_group(),
    iteration = "group",
    packages = c("tidyverse", "MESS")
  ),
  
  # SDD
  tar_target(
    name = p2_site_counts_grouped_sdd,
    command = add_download_groups(p2_site_counts_sdd, 
                                  max_sites = 100,
                                  max_results = 250000) %>%
      group_by(download_grp) %>%
      tar_group(),
    iteration = "group",
    packages = c("tidyverse", "MESS")
  ),
  
  # CDOM
  tar_target(
    name = p2_site_counts_grouped_cdom,
    command = add_download_groups(p2_site_counts_cdom, 
                                  max_sites = 100,
                                  max_results = 250000) %>%
      group_by(download_grp) %>%
      tar_group(),
    iteration = "group",
    packages = c("tidyverse", "MESS")
  ),
  
  
  # Fetch WQP data ----------------------------------------------------------
  
  # Now map over groups of sites to download data
  # Note that because error = 'continue', {targets} will attempt to build all 
  # of the "branches" represented by each unique combination of characteristic 
  # name and download group, even if one branch returns an error. This way, 
  # we will not need to re-build branches that have already run successfully. 
  # However, if a branch fails, {targets} will throw an error reading `could
  # not load dependencies of [immediate downstream target]. invalid 'description'
  # argument` because it cannot merge the individual branches and so did not  
  # complete the branching target. The error(s) associated with the failed branch 
  # will therefore need to be resolved before the full target can be successfully 
  # built. A common reason a branch may fail is due to WQP timeout errors. Timeout 
  # errors can sometimes be resolved by waiting a few hours and retrying tar_make().
  
  # Chlorophyll
  tar_target(
    name = p2_wqp_data_aoi_chl,
    command = fetch_wqp_data(p2_site_counts_grouped_chl,
                             char_names = unique(p2_site_counts_grouped_chl$CharacteristicName),
                             wqp_args = p0_wqp_args),
    pattern = map(p2_site_counts_grouped_chl),
    error = "continue",
    format = "feather",
    packages = c("dataRetrieval", "tidyverse", "sf", "retry")
  ),
  
  # CDOM
  tar_target(
    name = p2_wqp_data_aoi_cdom,
    command = fetch_wqp_data(p2_site_counts_grouped_cdom,
                             char_names = unique(p2_site_counts_grouped_cdom$CharacteristicName),
                             wqp_args = p0_wqp_args),
    pattern = map(p2_site_counts_grouped_cdom),
    error = "continue",
    format = "feather",
    packages = c("dataRetrieval", "tidyverse", "sf", "retry")
  ),
  
  # DOC
  tar_target(
    name = p2_wqp_data_aoi_doc,
    command = fetch_wqp_data(p2_site_counts_grouped_doc,
                             char_names = unique(p2_site_counts_grouped_doc$CharacteristicName),
                             wqp_args = p0_wqp_args),
    pattern = map(p2_site_counts_grouped_doc),
    error = "continue",
    format = "feather",
    packages = c("dataRetrieval", "tidyverse", "sf", "retry")
  ),
  
  # TSS
  tar_target(
    name = p2_wqp_data_aoi_tss,
    command = fetch_wqp_data(p2_site_counts_grouped_tss,
                             char_names = unique(p2_site_counts_grouped_tss$CharacteristicName),
                             wqp_args = p0_wqp_args),
    pattern = map(p2_site_counts_grouped_tss),
    error = "continue",
    format = "feather",
    packages = c("dataRetrieval", "tidyverse", "sf", "retry")
  ),
  
  # SDD
  tar_target(
    name = p2_wqp_data_aoi_sdd,
    command = fetch_wqp_data(p2_site_counts_grouped_sdd,
                             char_names = unique(p2_site_counts_grouped_sdd$CharacteristicName),
                             wqp_args = p0_wqp_args),
    pattern = map(p2_site_counts_grouped_sdd),
    error = "continue",
    format = "feather",
    packages = c("dataRetrieval", "tidyverse", "sf", "retry")
  ),
  
  # CDOM
  tar_target(
    name = p2_wqp_data_aoi_cdom,
    command = fetch_wqp_data(p2_site_counts_grouped_cdom,
                             char_names = unique(p2_site_counts_grouped_cdom$CharacteristicName),
                             wqp_args = p0_wqp_args),
    pattern = map(p2_site_counts_grouped_cdom),
    error = "continue",
    format = "feather",
    packages = c("dataRetrieval", "tidyverse", "sf", "retry")
  ),
  
  
  # Remove Personal Information from WQP data text columns ------------------
  # There are a few instances where organizations have submitted columns containing
  # personal information (emails or phone numbers) in comment text fields. We
  # want to make sure we do not pass that information on in our data products,
  # so this set of targets anonymizes emails and phone numbers for each parameter.
  
  # Chlorophyll
  tar_target(
    name = p2_wqp_data_aoi_chl_anon,
    command = anonymize_text(p2_wqp_data_aoi_chl),
    packages = "tidyverse",
    error = "stop"
  ),
  
  # CDOM
  tar_target(
    name = p2_wqp_data_aoi_cdom_anon,
    command = anonymize_text(p2_wqp_data_aoi_cdom),
    packages = "tidyverse",
    error = "stop"
  ),
  
  # DOC
  tar_target(
    name = p2_wqp_data_aoi_doc_anon,
    command = anonymize_text(p2_wqp_data_aoi_doc),
    packages = "tidyverse",
    error = "stop"
  ),
  
  # TSS
  tar_target(
    name = p2_wqp_data_aoi_tss_anon,
    command = anonymize_text(p2_wqp_data_aoi_tss),
    packages = "tidyverse",
    error = "stop"
  ),
  
  # SDD
  tar_target(
    name = p2_wqp_data_aoi_sdd_anon,
    command = anonymize_text(p2_wqp_data_aoi_sdd),
    packages = "tidyverse",
    error = "stop"
  ),
  
  
  # Export WQP data ---------------------------------------------------------
  
  # Chlorophyll
  tar_target(
    name = p2_wqp_data_aoi_chl_file,
    command = export_single_file(target = p2_wqp_data_aoi_chl_anon,
                                 drive_path = p0_chl_output_path,
                                 stable = p0_workflow_config$chl_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp,
                                 feather = TRUE),
    packages = c("tidyverse", "googledrive", "feather"),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # CDOM
  tar_target(
    name = p2_wqp_data_aoi_cdom_file,
    command = export_single_file(target = p2_wqp_data_aoi_cdom_anon,
                                 drive_path = p0_cdom_output_path,
                                 stable = p0_workflow_config$cdom_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp,
                                 feather = TRUE),
    packages = c("tidyverse", "googledrive", "feather"),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # DOC
  tar_target(
    name = p2_wqp_data_aoi_doc_file,
    command = export_single_file(target = p2_wqp_data_aoi_doc_anon,
                                 drive_path = p0_doc_output_path,
                                 stable = p0_workflow_config$doc_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp,
                                 feather = TRUE),
    packages = c("tidyverse", "googledrive", "feather"),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # TSS
  tar_target(
    name = p2_wqp_data_aoi_tss_file,
    command = export_single_file(target = p2_wqp_data_aoi_tss_anon,
                                 drive_path = p0_tss_output_path,
                                 stable = p0_workflow_config$tss_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp,
                                 feather = TRUE),
    packages = c("tidyverse", "googledrive", "feather"),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # SDD
  tar_target(
    name = p2_wqp_data_aoi_sdd_file,
    command = export_single_file(target = p2_wqp_data_aoi_sdd_anon,
                                 drive_path = p0_sdd_output_path,
                                 stable = p0_workflow_config$sdd_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp,
                                 feather = TRUE),
    packages = c("tidyverse", "googledrive", "feather"),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  # CDOM
  tar_target(
    name = p2_wqp_data_aoi_cdom_file,
    command = export_single_file(target = p2_wqp_data_aoi_cdom_anon,
                                 drive_path = p0_cdom_output_path,
                                 stable = p0_workflow_config$cdom_create_stable,
                                 google_email = p0_workflow_config$google_email,
                                 date_stamp = p0_date_stamp,
                                 feather = TRUE),
    packages = c("tidyverse", "googledrive", "feather"),
    cue = tar_cue("always"),
    error = "stop"
  ),
  
  
  # Summarize WQP pull ------------------------------------------------------
  
  # Summarize the data downloaded from the WQP
  
  # Chlorophyll
  tar_file(
    name = p2_wqp_data_chl_summary_csv,
    command = summarize_wqp_download(wqp_inventory_summary_csv = p1_wqp_inventory_chl_summary_csv,
                                     wqp_data = p2_wqp_data_aoi_chl_anon,
                                     "2_download/log/chl_summary_wqp_data.csv")
  ),
  
  # CDOM
  tar_file(
    name = p2_wqp_data_cdom_summary_csv,
    command = summarize_wqp_download(wqp_inventory_summary_csv = p1_wqp_inventory_cdom_summary_csv,
                                     wqp_data = p2_wqp_data_aoi_cdom_anon,
                                     "2_download/log/cdom_summary_wqp_data.csv")
  ),
  
  # DOC
  tar_file(
    name = p2_wqp_data_doc_summary_csv,
    command = summarize_wqp_download(wqp_inventory_summary_csv = p1_wqp_inventory_doc_summary_csv,
                                     wqp_data = p2_wqp_data_aoi_doc_anon,
                                     "2_download/log/doc_summary_wqp_data.csv")
  ),
  
  # TSS
  tar_file(
    name = p2_wqp_data_tss_summary_csv,
    command = summarize_wqp_download(wqp_inventory_summary_csv = p1_wqp_inventory_tss_summary_csv,
                                     wqp_data = p2_wqp_data_aoi_tss_anon,
                                     "2_download/log/tss_summary_wqp_data.csv")
  ),
  
  # SDD
  tar_file(
    name = p2_wqp_data_sdd_summary_csv,
    command = summarize_wqp_download(wqp_inventory_summary_csv = p1_wqp_inventory_sdd_summary_csv,
                                     wqp_data = p2_wqp_data_aoi_sdd_anon,
                                     "2_download/log/sdd_summary_wqp_data.csv")
  ),
  
  # CDOM
  tar_file(
    name = p2_wqp_data_cdom_summary_csv,
    command = summarize_wqp_download(wqp_inventory_summary_csv = p1_wqp_inventory_cdom_summary_csv,
                                     wqp_data = p2_wqp_data_aoi_cdom_anon,
                                     "2_download/log/cdom_summary_wqp_data.csv")
  ),
  
  
  # Get file IDs ------------------------------------------------------------
  
  # In order to access "stable" versions of the dataset created by the pipeline,
  # we get their Google Drive file IDs and store those in the repo so that
  # the harmonization pipeline can retrieve them more easily. The targets below
  # will include all file IDs in the Drive location, not just stable ones
  
  # Retrieve the IDs for the chlorophyll dataset
  tar_file_read(
    name = p2_chl_drive_ids,
    command = get_file_ids(google_email = p0_workflow_config$google_email,
                           drive_folder = p0_chl_output_path,
                           file_path = "2_download/out/chl_drive_ids.csv",
                           # Optional, indicates that this step depends on another
                           # target finishing first
                           depend = p2_wqp_data_aoi_chl_file
    ),
    read = read_csv(file = !!.x),
    cue = tar_cue("always"),
    packages = c("tidyverse", "googledrive")
  ), 
  
  # CDOM
  tar_file_read(
    name = p2_cdom_drive_ids,
    command = get_file_ids(google_email = p0_workflow_config$google_email,
                           drive_folder = p0_cdom_output_path,
                           file_path = "2_download/out/cdom_drive_ids.csv",
                           # Optional: What target(s) should this target wait on
                           # before running?
                           depend = p2_wqp_data_aoi_cdom_file
    ),
    read = read_csv(file = !!.x),
    cue = tar_cue("always"),
    packages = c("tidyverse", "googledrive")
  ), 
  
  # DOC
  tar_file_read(
    name = p2_doc_drive_ids,
    command = get_file_ids(google_email = p0_workflow_config$google_email,
                           drive_folder = p0_doc_output_path,
                           file_path = "2_download/out/doc_drive_ids.csv",
                           # Optional: What target(s) should this target wait on
                           # before running?
                           depend = p2_wqp_data_aoi_doc_file
    ),
    read = read_csv(file = !!.x),
    cue = tar_cue("always"),
    packages = c("tidyverse", "googledrive")
  ), 
  
  # TSS
  tar_file_read(
    name = p2_tss_drive_ids,
    command = get_file_ids(google_email = p0_workflow_config$google_email,
                           drive_folder = p0_tss_output_path,
                           file_path = "2_download/out/tss_drive_ids.csv",
                           # Optional: What target(s) should this target wait on
                           # before running?
                           depend = p2_wqp_data_aoi_tss_file
    ),
    read = read_csv(file = !!.x),
    cue = tar_cue("always"),
    packages = c("tidyverse", "googledrive")
  ), 
  
  # SDD
  tar_file_read(
    name = p2_sdd_drive_ids,
    command = get_file_ids(google_email = p0_workflow_config$google_email,
                           drive_folder = p0_sdd_output_path,
                           file_path = "2_download/out/sdd_drive_ids.csv",
                           depend = p2_wqp_data_aoi_sdd_file
    ),
    read = read_csv(file = !!.x),
    cue = tar_cue("always"),
    packages = c("tidyverse", "googledrive")
  ),
  
  # CDOM
  tar_file_read(
    name = p2_cdom_drive_ids,
    command = get_file_ids(google_email = p0_workflow_config$google_email,
                           drive_folder = p0_cdom_output_path,
                           file_path = "2_download/out/cdom_drive_ids.csv",
                           depend = p2_wqp_data_aoi_cdom_file
    ),
    read = read_csv(file = !!.x),
    cue = tar_cue("always"),
    packages = c("tidyverse", "googledrive")
  ),
  
  # General purpose
  tar_file_read(
    name = p2_general_drive_ids,
    command = get_file_ids(google_email = p0_workflow_config$google_email,
                           drive_folder = p0_general_output_path,
                           file_path = "2_download/out/general_drive_ids.csv",
                           depend = p1_global_grid_file
    ),
    read = read_csv(file = !!.x),
    cue = tar_cue("always"),
    packages = c("tidyverse", "googledrive")
  )
  
  
)