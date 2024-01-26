# Source the functions that will be used to build the targets in p2_targets_list
tar_source("2_download/src/")

p2_targets_list <- list(
  
  # Pull site IDs and total number of records for each site from the WQP inventory
  tar_target(
    p2_site_counts,
    p1_wqp_inventory_aoi %>%
      # Hold onto location info, grid_id, characteristic, and provider data
      # and use them for grouping
      group_by(MonitoringLocationIdentifier, lon, lat, datum, grid_id,
               CharacteristicName, ProviderName) %>%
      # Count the number of rows per group
      summarize(results_count = sum(resultCount, na.rm = TRUE),
                .groups = "drop") %>%
      # Add the overarching parameter names to the dataset
      left_join(x = .,
                y = p1_wqp_params %>%
                  map2_df(.x,
                          .y = names(.),
                          .f = ~{
                            tibble(CharacteristicName = .x,
                                   parameter = .y)
                          }),
                by = "CharacteristicName") %>%
      group_by(parameter) %>%
      # In case of testing:
      # Split dataset into a list for iterating downloads by parameter
      split(f = .$parameter)
  ),
  
  # Use {googledrive} to upload the site counts data, which will be needed in
  # the second pipeline. Then return a file containing the link as text to be 
  # used outside of this pipeline
  tar_file(p2_site_counts_link,
           export_single_file(target = p2_site_counts,
                              folder_pattern = "2_download/out/")),
  
  tar_target(
    p2_site_counts_grouped_chl,
    add_download_groups(p2_site_counts$chlorophyll, 
                        max_sites = 100,
                        max_results = 250000) %>%
      group_by(download_grp) %>%
      tar_group(),
    iteration = "group",
    packages = c("tidyverse", "MESS")
  ),
  
  tar_target(
    p2_wqp_data_aoi_chl,
    fetch_wqp_data(p2_site_counts_grouped_chl,
                   char_names = unique(p2_site_counts_grouped_chl$CharacteristicName),
                   wqp_args = p0_wqp_args),
    pattern = map(p2_site_counts_grouped_chl),
    error = "continue",
    format = "feather",
    packages = c("dataRetrieval", "tidyverse", "sf", "retry")
  ),
  
  # A named list of the datasets to facilitate exporting them to Google Drive
  tar_target(p2_wqp_data_aoi_list,
             list(
               "chlorophyll" = p2_wqp_data_aoi_chl
             )),
  
  # Use {googledrive} to upload the final outputs of this pipeline, then return
  # a file containing the links as text to be used outside of this pipeline
  tar_file(p2_wqp_data_aoi_out_links,
           {
             # The result of this will be a data frame with one col for the
             # parameter being exported and another col with a link to the
             # exported data set in Google Drive
             drive_links <- p2_wqp_data_aoi_list %>%
               map2_df(.x = .,
                       # Names of the sub-data sets above
                       .y = names(.),
                       .f = ~ {
                         
                         # We'll export each parameter's data set locally
                         file_local_path <- paste0("2_download/out/p2_wqp_data_aoi_",
                                                   .y,
                                                   ".feather")
                         write_feather(x = .x,
                                       path = file_local_path)
                         
                         # Once locally exported, send to Google Drive
                         out_file <- drive_put(media = file_local_path,
                                               path = "~/aquamatch_download_wqp/chla_submission/")
                         
                         # Make the Google Drive link shareable: anyone can view
                         out_file_share <- out_file %>%
                           drive_share(role = "reader", type = "anyone")
                         
                         # Return labeled link to stack in a df and export
                         tibble(parameter = .y,
                                local_path = file_local_path,
                                drive_link = drive_link(as_id(out_file_share$id)))
                         
                       })
             
             # Where the csv of Drive links is going
             out_path <- "2_download/out/p2_wqp_data_aoi_out_links.csv"
             
             # Export the csv
             write_csv(x = drive_links, file = out_path)
             
             # Return path to pipeline
             out_path
             
           },
           packages = c("tidyverse", "googledrive", "feather")),
  
  # Summarize the data downloaded from the WQP
  tar_target(
    p2_wqp_data_summary_csv,
    summarize_wqp_download(wqp_inventory_summary_csv = p1_wqp_inventory_summary_csv,
                           wqp_data = bind_rows(p2_wqp_data_aoi_list),
                           "2_download/log/summary_wqp_data.csv"),
    format = "file"
  )
  
)