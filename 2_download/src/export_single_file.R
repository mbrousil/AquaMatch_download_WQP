# A function to export a single target (as a file) to Google Drive and return
# the shareable Drive link as a filepath
export_single_file <- function(target, folder_pattern){
  
  require(googledrive)
  
  # Get target name as a string
  target_string <- deparse(substitute(target))
  
  # We'll export the dataset locally
  file_local_path <- paste0(folder_pattern,
                            target_string,
                            ".rds")
  
  write_rds(x = target,
            path = file_local_path)
  
  # Once locally exported, send to Google Drive
  out_file <- drive_put(media = file_local_path,
                        path = "~/aquamatch_download_wqp/")
  
  # Make the Google Drive link shareable: anyone can view
  out_file_share <- out_file %>%
    drive_share(role = "reader", type = "anyone")
  
  # Return labeled link to data in a df and export
  link_table <- tibble(dataset = target_string,
                       local_path = file_local_path,
                       drive_link = drive_link(as_id(out_file_share$id)))
  
  # Where the csv with Drive link is going
  out_path <- paste0(folder_pattern,
                     target_string,
                     "_out_link.csv")
  
  # Export the csv
  write_csv(x = link_table, file = out_path)
  
  # Return path to pipeline
  out_path
  
}