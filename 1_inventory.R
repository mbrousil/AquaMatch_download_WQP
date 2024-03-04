# Source the functions that will be used to build the targets in p1_targets_list
tar_source("1_inventory/src/")


p1_targets_list <- list(
  
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
  
  # Dissolved organic carbon
  tar_target(
    name = p1_wqp_params_doc,
    command = p1_wqp_params["doc"]
  ),
  
  # Secchi disk depth
  tar_target(
    name = p1_wqp_params_sdd,
    command = p1_wqp_params["sdd"]
  ),
  
  # Use {googledrive} to upload each parameter's yaml data. It will be needed in
  # the second pipeline. Then return a file containing the link as text to be 
  # accessed outside of this pipeline
  
  # Chlorophyll
  tar_file(
    name = p1_wqp_params_link_chl,
    command = export_single_file(target = p1_wqp_params_chl,
                                 folder_pattern = "1_inventory/out/")
  ),
  
  # DOC
  tar_file(
    name = p1_wqp_params_link_doc,
    command = export_single_file(target = p1_wqp_params_doc,
                                 folder_pattern = "1_inventory/out/")
  ),
  
  # SDD
  tar_file(
    name = p1_wqp_params_link_sdd,
    command = export_single_file(target = p1_wqp_params_sdd,
                                 folder_pattern = "1_inventory/out/")
  ),
  
  # An alternative to the links generated in the step above. This option provides
  # quick way to access previously-generated yaml parameter data if a long-term stable
  # version is needed.
  
  # Chlorophyll
  tar_file(
    name = p1_wqp_params_chl_link_stable,
    command = export_stable_link(
      out_path = "1_inventory/out/p1_wqp_params_chl_out_link_stable.csv",
      dataset_string = "p1_wqp_params_chl",
      local_path = "1_inventory/out/p1_wqp_params_chl.rds",
      drive_link = "https://drive.google.com/file/d/1ntVfkSbpubYAdVGqQIrClm0F-61ZZrJ-/view?usp=drive_link"
    )
  ),
  
  # DOC
  tar_file(
    name = p1_wqp_params_doc_link_stable,
    command = export_stable_link(
      out_path = "1_inventory/out/p1_wqp_params_doc_out_link_stable.csv",
      dataset_string = "p1_wqp_params_doc",
      local_path = "1_inventory/out/p1_wqp_params_doc.rds",
      drive_link = "https://drive.google.com/file/d/1usukc6QG0gV0wTKq-yi1qZ02FXIIFP1A/view?usp=drive_link"
    )
  ),
  
  # SDD
  tar_file(
    name = p1_wqp_params_sdd_link_stable,
    command = export_stable_link(
      out_path = "1_inventory/out/p1_wqp_params_sdd_out_link_stable.csv",
      dataset_string = "p1_wqp_params_sdd",
      local_path = "1_inventory/out/p1_wqp_params_sdd.rds",
      drive_link = "https://drive.google.com/file/d/1l1Kt-fAEsTKaZjIdGXYp3gYypqmC5aPf/view?usp=sharing"
    )
  ),
  
  
  # Format tables that indicate how various WQP characteristic names map onto 
  # each parameter name
  
  # Chlorophyll
  tar_target(
    name = p1_char_names_crosswalk_chl,
    command = crosswalk_characteristics(p1_wqp_params_chl)
  ),
  
  # DOC
  tar_target(
    name = p1_char_names_crosswalk_doc,
    command = crosswalk_characteristics(p1_wqp_params_doc)
  ),
  
  # SDD
  tar_target(
    name = p1_char_names_crosswalk_sdd,
    command = crosswalk_characteristics(p1_wqp_params_sdd)
  ),
  
  
  # Use {googledrive} to upload the crosswalk data, which will be needed in
  # the second pipeline. Then return a file containing the link as text to be 
  # used outside of this pipeline
  
  # Chlorophyll
  tar_file(
    name = p1_char_names_crosswalk_chl_link,
    command = export_single_file(target = p1_char_names_crosswalk_chl,
                                 folder_pattern = "1_inventory/out/")
  ),
  
  # DOC
  tar_file(
    name = p1_char_names_crosswalk_doc_link,
    command = export_single_file(target = p1_char_names_crosswalk_doc,
                                 folder_pattern = "1_inventory/out/")
  ), 
  
  # SDD
  tar_file(
    name = p1_char_names_crosswalk_sdd_link,
    command = export_single_file(target = p1_char_names_crosswalk_sdd,
                                 folder_pattern = "1_inventory/out/")
  ),
  
  
  # An alternative to the link generated in the step above. This option provides
  # quick way to access previously-created CharacteristicName to parameter name
  # crosswalk if a long-term stable version is needed.
  
  # Chlorophyll
  tar_file(
    name = p1_char_names_crosswalk_chl_link_stable,
    command = export_stable_link(
      out_path = "1_inventory/out/p1_char_names_crosswalk_out_chl_link_stable.csv",
      dataset_string = "p1_char_names_crosswalk_chl",
      local_path = "1_inventory/out/p1_char_names_crosswalk_chl.rds",
      drive_link = ""
    )
  ),
  
  # DOC
  tar_file(
    name = p1_char_names_crosswalk_doc_link_stable,
    command = export_stable_link(
      out_path = "1_inventory/out/p1_char_names_crosswalk_out_doc_link_stable.csv",
      dataset_string = "p1_char_names_crosswalk_doc",
      local_path = "1_inventory/out/p1_char_names_crosswalk_doc.rds",
      drive_link = ""
    )
  ),
  
  # SDD
  tar_file(
    name = p1_char_names_crosswalk_sdd_link_stable,
    command = export_stable_link(
      out_path = "1_inventory/out/p1_char_names_crosswalk_out_sdd_link_stable.csv",
      dataset_string = "p1_char_names_crosswalk_sdd",
      local_path = "1_inventory/out/p1_char_names_crosswalk_sdd.rds",
      drive_link = ""
    )
  ),
  
  
  # Get a vector of WQP characteristic names to match parameter groups of interest
  
  # Chlorophyll
  tar_target(
    name = p1_char_names_chl,
    command = filter_characteristics(p1_char_names_crosswalk_chl, p0_param_groups_select),
    packages = c("tidyverse", "xml2")
  ),
  
  # DOC
  tar_target(
    name = p1_char_names_doc,
    command = filter_characteristics(p1_char_names_crosswalk_doc, p0_param_groups_select),
    packages = c("tidyverse", "xml2")
  ),
  
  # SDD
  tar_target(
    name = p1_char_names_sdd,
    command = filter_characteristics(p1_char_names_crosswalk_sdd, p0_param_groups_select),
    packages = c("tidyverse", "xml2")
  ),
  
  
  # Save output file(s) containing WQP characteristic names that are similar to the
  # parameter groups of interest. This allows users to examine the list to see if there are other
  # parameters that they may wish to add to the yaml file for each parameter, stored in
  # p1_wqp_params.
  tar_file(
    name = p1_similar_char_names_chl_txt,
    command = find_similar_characteristics(p1_char_names_chl,
                                           "chlorophyll",
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
    name = p1_similar_char_names_sdd_txt,
    command = find_similar_characteristics(p1_char_names_sdd,
                                           "sdd",
                                           "1_inventory/out"),
    packages = c("tidyverse", "xml2")
  ),
  
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
  tar_file(
    name = p1_global_grid_link,
    command = export_single_file(target = p1_global_grid,
                                 folder_pattern = "1_inventory/out/")
  ),
  
  # An alternative to the link generated in the step above. This option provides
  # quick way to access previously-generated spatial grid if a long-term stable
  # version is needed.
  tar_file(
    name = p1_global_grid_link_stable,
    command = export_stable_link(
      out_path = "1_inventory/out/p1_global_grid_out_link_stable.csv",
      dataset_string = "p1_global_grid",
      local_path = "1_inventory/out/p1_global_grid.rds",
      drive_link = "https://drive.google.com/file/d/1zKgAzXpWwMiVvJT2IMHW6kou5ijDsqgO/view?usp=drive_link"
    )
  ),
  
  
  # Use spatial subsetting to find boxes that overlap the area of interest
  # These boxes will be used to query the WQP.
  tar_target(
    name = p1_global_grid_aoi,
    command = subset_grids_to_aoi(p1_global_grid, p1_AOI_sf),
    packages = c("tidyverse", "units")
  ),
  
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
  
  
  # Subset the WQP inventory to only retain sites within the area of interest
  
  # Chlorophyll
  tar_target(
    name = p1_wqp_inventory_aoi_chl,
    command = subset_inventory(p1_wqp_inventory_chl, p1_AOI_sf)
  ),
  
  # DOC
  tar_target(
    name = p1_wqp_inventory_aoi_doc,
    command = subset_inventory(p1_wqp_inventory_doc, p1_AOI_sf)
  ),
  
  # SDD
  tar_target(
    name = p1_wqp_inventory_aoi_sdd,
    command = subset_inventory(p1_wqp_inventory_sdd, p1_AOI_sf)
  ),
  
  # Use {googledrive} to upload the inventory data, which will be needed in
  # the second pipeline. Then return a file containing the link as text to be 
  # used outside of this pipeline
  
  # Chlorophyll
  tar_file(
    name = p1_wqp_inventory_aoi_chl_link,
    command = export_single_file(target = p1_wqp_inventory_aoi_chl,
                                 folder_pattern = "1_inventory/out/")
  ),
  
  # DOC
  tar_file(
    name = p1_wqp_inventory_aoi_doc_link,
    command = export_single_file(target = p1_wqp_inventory_aoi_doc,
                                 folder_pattern = "1_inventory/out/")
  ),
  
  # SDD
  tar_file(
    name = p1_wqp_inventory_aoi_sdd_link,
    command = export_single_file(target = p1_wqp_inventory_aoi_sdd,
                                 folder_pattern = "1_inventory/out/")
  ),
  
  # An alternative to the link generated in the step above. This option provides
  # quick way to access previously-downloaded inventory data if a long-term stable
  # version is needed.
  
  # Chlorophyll
  tar_file(
    name = p1_wqp_inventory_aoi_chl_link_stable,
    command = export_stable_link(
      out_path = "1_inventory/out/p1_wqp_inventory_aoi_out_chl_link_stable.csv",
      dataset_string = "p1_wqp_inventory_aoi",
      local_path = "1_inventory/out/p1_wqp_inventory_aoi_chl.rds",
      drive_link = ""
    )
  ),
  
  # DOC
  tar_file(
    name = p1_wqp_inventory_aoi_doc_link_stable,
    command = export_stable_link(
      out_path = "1_inventory/out/p1_wqp_inventory_aoi_out_doc_link_stable.csv",
      dataset_string = "p1_wqp_inventory_aoi",
      local_path = "1_inventory/out/p1_wqp_inventory_aoi_doc.rds",
      drive_link = ""
    )
  ),
  
  # SDD
  tar_file(
    name = p1_wqp_inventory_aoi_sdd_link_stable,
    command = export_stable_link(
      out_path = "1_inventory/out/p1_wqp_inventory_aoi_out_sdd_link_stable.csv",
      dataset_string = "p1_wqp_inventory_aoi",
      local_path = "1_inventory/out/p1_wqp_inventory_aoi_sdd.rds",
      drive_link = ""
    )
  ),
  
  # Summarize the data that would come back from the WQP
  
  # Chlorophyll
  tar_file(
    name = p1_wqp_inventory_chl_summary_csv,
    command = summarize_wqp_inventory(p1_wqp_inventory_aoi_chl,
                                      "1_inventory/log/chl_summary_wqp_inventory.csv")
  ),
  
  # DOC
  tar_file(
    name = p1_wqp_inventory_doc_summary_csv,
    command = summarize_wqp_inventory(p1_wqp_inventory_aoi_doc,
                                      "1_inventory/log/doc_summary_wqp_inventory.csv")
  ),
  
  # SDD
  tar_file(
    name = p1_wqp_inventory_sdd_summary_csv,
    command = summarize_wqp_inventory(p1_wqp_inventory_aoi_sdd,
                                      "1_inventory/log/sdd_summary_wqp_inventory.csv")
  )
  
  
)
