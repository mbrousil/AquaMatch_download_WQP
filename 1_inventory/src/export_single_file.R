#' @title Export a single target to Google Drive
#' 
#' @description
#' A function to export a single target (as a file) to Google Drive and return
#' the shareable Drive link as a file path.
#' 
#' @param target The name of the target to be exported (as an object not a string).
#' 
#' @param drive_path A path to the folder on Google Drive where the file
#' should be saved.
#' 
#' @param stable Logical value. If TRUE, also export the file to the "stable"
#' subfolder in Google Drive. If FALSE, use the path as provided by the user.
#' 
#' @param google_email A string containing the gmail address to use for
#' Google Drive authentication.
#' 
#' @returns 
#' Returns a local path to a csv file containing a text link to the uploaded
#' file in Google Drive.
#' 
export_single_file <- function(target, drive_path, stable, google_email){
  
  # Authorize using the google email provided
  drive_auth(google_email)
  
  # Get target name as a string
  target_string <- deparse(substitute(target))
  
  # Create a temporary file exported locally, which can then be used to upload
  # to Google Drive
  file_local_path <- tempfile(fileext = ".rds")
  
  write_rds(x = target,
            file = file_local_path)
  
  # Once locally exported, send to Google Drive
  out_file <- drive_put(media = file_local_path,
                        # The folder on Google Drive
                        path = drive_path,
                        # The filename on Google Drive
                        name = paste0(target_string, ".rds"))
  
  # Make the Google Drive link shareable: anyone can view
  drive_share_anyone(out_file)
  
  # If stable == TRUE then export a second, dated file to the stable/ subfolder
  if(stable){
    drive_path_stable <- paste0(drive_path, "stable/")
    
    # Once locally exported, send to Google Drive
    out_file_stable <- drive_put(media = file_local_path,
                                 # The folder on Google Drive
                                 path = drive_path_stable,
                                 # The filename on Google Drive
                                 name = paste0(target_string,
                                               "_",
                                               gsub(pattern = "-",
                                                    replacement = "",
                                                    x = Sys.Date()),
                                               ".rds"))
    
    # Make the Google Drive link shareable: anyone can view
    drive_share(out_file_stable, role = "reader", type = "anyone")
  }
  
  # Now remove the local file after upload is complete
  file.remove(file_local_path)
  
}

# A function that creates a local file containing a link to a stable version
# of one of the datasets in the pipeline. NOTE that it does not export a dataset
# to Google Drive, only provides a link to an existing dataset in Google Drive.

# out_path: Where the csv containing the link to Google Drive will be saved locally
# dataset_string: A character string containing the name of the target that is being referenced
# local_path: The location of the target's dataset locally. NOTE that this field is not used to access any file. It is present for use when specifying a download path in the second pipeline.
# drive_link: A link to the Google Drive file containing the stable version of the dataset
export_stable_link <- function(out_path, dataset_string, local_path, drive_link){
  
  stable_drive_links <- tribble(
    ~dataset, ~local_path, ~drive_link,
    dataset_string, local_path, drive_link
  )
  
  # Export the csv
  write_csv(x = stable_drive_links, file = out_path)
  
  # Return path to pipeline
  out_path
  
}
