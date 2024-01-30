# Source the functions that will be used to build the targets in p1_targets_list
tar_source("1_inventory/src/")


p1_targets_list <- list(
  
  # Track yml file containing common parameter groups and WQP characteristic names
  # If {targets} detects a change in the yml file, it will re-build all downstream
  # targets that depend on p1_wqp_params_yml assuming that p0_param_groups_select
  # indicates that any new parameters should be included in the pipeline.
  tar_file_read(
    p1_wqp_params,
    "1_inventory/cfg/wqp_codes.yml",
    read = read_yaml(!!.x),
    packages = "yaml"
  ),
  
  # Use {googledrive} to upload the yaml parameter data, which will be needed in
  # the second pipeline. Then return a file containing the link as text to be 
  # used outside of this pipeline
  tar_file(p1_wqp_params_link,
           export_single_file(target = p1_wqp_params,
                              folder_pattern = "1_inventory/out/")),
  
  # An alternative to the link generated in the step above. This option provides
  # quick way to access previously-generated yaml parameter data if a long-term stable
  # version is needed.
  tar_file(p1_wqp_params_link_stable,
           {
             # Where the Drive link csv is going
             out_path <- "1_inventory/out/p1_wqp_params_out_link_stable.csv"
             
             stable_drive_links <- tribble(
               ~dataset, ~local_path, ~drive_link,
               "p1_wqp_params", "1_inventory/out/p1_wqp_params.rds", "https://drive.google.com/file/d/1mOJpB7jUFQ9PPzbVI902rmYQ7awFWnIv/view?usp=drive_link"
             )
             
             # Export the csv
             write_csv(x = stable_drive_links, file = out_path)
             
             # Return path to pipeline
             out_path
           }),
  
  # Format a table that indicates how various WQP characteristic names map onto 
  # more commonly-used parameter names
  tar_target(
    p1_char_names_crosswalk,
    crosswalk_characteristics(p1_wqp_params)
  ),
  
  # Use {googledrive} to upload the crosswalk data, which will be needed in
  # the second pipeline. Then return a file containing the link as text to be 
  # used outside of this pipeline
  tar_file(p1_char_names_crosswalk_link,
           export_single_file(target = p1_char_names_crosswalk,
                              folder_pattern = "1_inventory/out/")),
  
  # An alternative to the link generated in the step above. This option provides
  # quick way to access previously-created CharacteristicName to parameter name
  # crosswalk if a long-term stable version is needed.
  tar_file(p1_char_names_crosswalk_link_stable,
           {
             # Where the Drive link csv is going
             out_path <- "1_inventory/out/p1_char_names_crosswalk_out_link_stable.csv"
             
             stable_drive_links <- tribble(
               ~dataset, ~local_path, ~drive_link,
               "p1_char_names_crosswalk", "1_inventory/out/p1_char_names_crosswalk.rds", "https://drive.google.com/file/d/1YYk3r7-SnRxxhdh5qWZgd57ytbR0q1Ze/view?usp=drive_link"
             )
             
             # Export the csv
             write_csv(x = stable_drive_links, file = out_path)
             
             # Return path to pipeline
             out_path
           }),
  
  # Get a vector of WQP characteristic names to match parameter groups of interest
  tar_target(
    p1_char_names,
    filter_characteristics(p1_char_names_crosswalk, p0_param_groups_select),
    packages = c("tidyverse", "xml2")
  ),
  
  # Save output file(s) containing WQP characteristic names that are similar to the
  # parameter groups of interest.
  tar_file(
    p1_similar_char_names_txt,
    find_similar_characteristics(p1_char_names,
                                 p0_param_groups_select,
                                 "1_inventory/out"),
    packages = c("tidyverse", "xml2")
  ),
  
  tar_target(
    p1_AOI_sf,
    states(),
    packages = c("tidyverse", "tigris")),
  
  # Create a big grid of boxes to set up chunked data queries.
  # The resulting grid, which covers the globe, allows for queries
  # outside of CONUS, including AK, HI, and US territories. 
  tar_target(
    p1_global_grid,
    create_global_grid(),
    packages = c("tidyverse", "sf")
  ),
  
  # Use {googledrive} to upload the global grid data, which will be needed in
  # the second pipeline. Then return a file containing the link as text to be 
  # used outside of this pipeline
  tar_file(p1_global_grid_link,
           export_single_file(target = p1_global_grid,
                              folder_pattern = "1_inventory/out/")),
  
  # An alternative to the link generated in the step above. This option provides
  # quick way to access previously-generated spatial grid if a long-term stable
  # version is needed.
  tar_file(p1_global_grid_link_stable,
           {
             # Where the Drive link csv is going
             out_path <- "1_inventory/out/p1_global_grid_out_link_stable.csv"
             
             stable_drive_links <- tribble(
               ~dataset, ~local_path, ~drive_link,
               "p1_global_grid", "1_inventory/out/p1_global_grid.rds", "https://drive.google.com/file/d/15KmSrcia9Alw5Q637UNsq7TuTXJGCS4D/view?usp=drive_link"
             )
             
             # Export the csv
             write_csv(x = stable_drive_links, file = out_path)
             
             # Return path to pipeline
             out_path
           }),
  
  # Use spatial subsetting to find boxes that overlap the area of interest
  # These boxes will be used to query the WQP.
  tar_target(
    p1_global_grid_aoi,
    subset_grids_to_aoi(p1_global_grid, p1_AOI_sf),
    packages = c("tidyverse", "units")
  ),
  
  # Inventory data available from the WQP within each of the boxes that overlap
  # the area of interest. To prevent timeout issues that result from large data 
  # requests, use {targets} dynamic branching capabilities to map the function 
  # inventory_wqp() over each grid within p1_global_grid_aoi. {targets} will then
  # combine all of the grid-scale inventories into one table. See comments above
  # target p2_wqp_data_aoi (in 2_download.R) regarding the use of error = 'continue'.
  tar_target(
    p1_wqp_inventory,
    {
      # inventory_wqp() requires grid and char_names as inputs, but users can 
      # also pass additional arguments to WQP, e.g. sampleMedia or siteType, using 
      # wqp_args. Below, wqp_args is defined in _targets.R. See documentation
      # in 1_fetch/src/get_wqp_inventory.R for further details.
      inventory_wqp(grid = p1_global_grid_aoi,
                    char_names = p1_char_names,
                    wqp_args = p0_wqp_args)
    },
    pattern = cross(p1_global_grid_aoi, p1_char_names),
    error = "continue",
    packages = c("tidyverse", "retry", "sf", "dataRetrieval", "units")
  ),
  
  # Subset the WQP inventory to only retain sites within the area of interest
  tar_target(
    p1_wqp_inventory_aoi,
    subset_inventory(p1_wqp_inventory, p1_AOI_sf)
  ),
  
  # Use {googledrive} to upload the inventory data, which will be needed in
  # the second pipeline. Then return a file containing the link as text to be 
  # used outside of this pipeline
  tar_file(p1_wqp_inventory_aoi_link,
           export_single_file(target = p1_wqp_inventory_aoi,
                              folder_pattern = "1_inventory/out/")),
  # An alternative to the link generated in the step above. This option provides
  # quick way to access previously-downloaded inventory data if a long-term stable
  # version is needed.
  tar_file(p1_wqp_inventory_aoi_link_stable,
           {
             # Where the Drive link csv is going
             out_path <- "1_inventory/out/p1_wqp_inventory_aoi_out_link_stable.csv"
             
             stable_drive_links <- tribble(
               ~dataset, ~local_path, ~drive_link,
               "p1_wqp_inventory_aoi", "1_inventory/out/p1_wqp_inventory_aoi.rds", "https://drive.google.com/file/d/18D3zpsxyb-SAmlywLRwHHfNsxpecf9JU/view?usp=drive_link"
             )
             
             # Export the csv
             write_csv(x = stable_drive_links, file = out_path)
             
             # Return path to pipeline
             out_path
           }),
  
  # Summarize the data that would come back from the WQP
  tar_file(
    p1_wqp_inventory_summary_csv,
    summarize_wqp_inventory(p1_wqp_inventory_aoi,
                            "1_inventory/log/summary_wqp_inventory.csv")
  )
  
  
)
