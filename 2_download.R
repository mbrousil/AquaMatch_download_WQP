# Source the functions that will be used to build the targets in p2_targets_list
tar_source("2_download/src/")

p2_targets_list <- list(
  
  # Pull site IDs and total number of records for each site from the WQP inventory
  tar_target(
    name = p2_site_counts,
    command = p1_wqp_inventory_aoi %>%
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
  tar_file(
    name = p2_site_counts_link,
    command = export_single_file(target = p2_site_counts,
                                 folder_pattern = "2_download/out/")
  ),
  
  # An alternative to the link generated in the step above. This option provides
  # quick way to access a previously-created site inventory if a long-term stable
  # version is needed.
  tar_file(
    name = p2_site_counts_link_stable,
    command = {
      # Where the Drive link csv is going
      out_path <- "2_download/out/p2_site_counts_out_link_stable.csv"
      
      stable_drive_links <- tribble(
        ~dataset, ~local_path, ~drive_link,
        "p2_site_counts", "2_download/out/p2_site_counts.rds", "https://drive.google.com/file/d/1gB4CkTuvCYQaaaVJYwIx7jMt7uxOcNpq/view?usp=drive_link"
      )
      
      # Export the csv
      write_csv(x = stable_drive_links, file = out_path)
      
      # Return path to pipeline
      out_path
    }
  ),
  
  # Group the site counts separately for each parameter in the pipeline:
  # Chlorophyll
  tar_target(
    name = p2_site_counts_grouped_chl,
    command = add_download_groups(p2_site_counts$chlorophyll, 
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
    command = add_download_groups(p2_site_counts$doc, 
                                  max_sites = 100,
                                  max_results = 250000) %>%
      group_by(download_grp) %>%
      tar_group(),
    iteration = "group",
    packages = c("tidyverse", "MESS")
  ),
  
  # Secchi disk depth
  tar_target(
    name = p2_site_counts_grouped_sdd,
    command = add_download_groups(p2_site_counts$sdd, 
                                  max_sites = 100,
                                  max_results = 250000) %>%
      group_by(download_grp) %>%
      tar_group(),
    iteration = "group",
    packages = c("tidyverse", "MESS")
  ),
  
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
  
  # A named list of the datasets to facilitate exporting them to Google Drive
  tar_target(
    name = p2_wqp_data_aoi_list,
    command = list(
      "chlorophyll" = p2_wqp_data_aoi_chl,
      "doc" = p2_wqp_data_aoi_doc,
      "sdd" = p2_wqp_data_aoi_sdd
    )
  ),
  
  # Use {googledrive} to upload the final outputs of this pipeline, then return
  # a file containing the links as text to be used outside of this pipeline
  tar_file(
    name = p2_wqp_data_aoi_out_links,
    command = {
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
                                        path = "~/aquamatch_download_wqp/")
                  
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
    packages = c("tidyverse", "googledrive", "feather")
  ),
  
  # An alternative to the links generated in the step above. This option provides
  # quick way to access previously-downloaded WQP datasets if a long-term stable
  # version is needed.
  tar_file(
    name = p2_wqp_data_aoi_out_links_stable,
    command = {
      # Where the csv of Drive links is going
      out_path <- "2_download/out/p2_wqp_data_aoi_out_links_stable.csv"
      
      stable_drive_links <- tribble(
        ~parameter, ~local_path, ~drive_link,
        "chlorophyll", "2_download/out/p2_wqp_data_aoi_chlorophyll.feather", "https://drive.google.com/file/d/1LIxxp7Gb5oyTDyusAN0yvmUT4wbY0ZOX/view?usp=drive_link",
        "doc", "2_download/out/p2_wqp_data_aoi_doc.feather", "https://drive.google.com/file/d/1RG9FAxoZAhjD71G3XPJJqDqsdWpikhln/view?usp=drive_link",
        "tss", "2_download/out/p2_wqp_data_aoi_tss.feather", "https://drive.google.com/file/d/1gt8_VsLnTfNna1rZBNN5IIxNRBZwuhR8/view?usp=drive_link",
        "sdd", "2_download/out/p2_wqp_data_aoi_sdd.feather", "https://drive.google.com/file/d/1Kw57jN0O-Vz94OrgYKL5WuISvjGH4Mxl/view?usp=drive_link"
      )
      
      # Export the csv
      write_csv(x = stable_drive_links, file = out_path)
      
      # Return path to pipeline
      out_path
    }
  ),
  
  # Summarize the data downloaded from the WQP
  tar_target(
    name = p2_wqp_data_summary_csv,
    command = summarize_wqp_download(wqp_inventory_summary_csv = p1_wqp_inventory_summary_csv,
                                     wqp_data = bind_rows(p2_wqp_data_aoi_list),
                                     "2_download/log/summary_wqp_data.csv"),
    format = "file"
  )
  
)