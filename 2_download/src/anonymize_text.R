#' Function to anonymize text in the text comments columns of WQP
#' 
#' @description
#' This function anonymizes email addresses and phone numbers, which occasionally
#' show up in comment text columns of Water Quality Portal pulls.
#' 
#' 
#' @param data dataframe or targets object containing columns with strings that 
#' may have personal information in them (emails and phone numbers)
#' @param column column names with text comments requiring anonymization, this
#' defaults to `ActivityCommentText`, `ResultLaboratoryCommentText`, and
#' `ResultCommentText`, but can be replaced with other column names.
#' 
#' @returns This function returns the same shape of dataframe (rows x columns)
#' but with strings that match common email and phone formats anonymized. For 
#' email addresses, all characters prior to the `@` symbol are replace with `xxxx`
#' and for phone numbers all digits are replaced by `xxxxxxxxxx`.
#' 
#' @example anonymize_text(p2_wqp_data_aoi_sdd)
#' 

anonymize_text <- function(data, 
                           columns = c("ActivityCommentText", 
                                       "ResultLaboratoryCommentText", 
                                       "ResultCommentText")) {
  
  # define the full phone and email patterns using regex
  phone_pat <- "(?:^|\\D)((?:\\+?1[-.]?)?\\s*\\(?[2-9]\\d{2}\\)?[-.]?\\s*\\d{3}[-.]?\\s*\\d{4})(?:$|\\D)"
  email_pat <- "[a-zA-Z0-9._%+-]+\\s*@\\s*[a-zA-Z0-9.-]+[\\.,][a-zA-Z]{2,}"
  
  # add a rowid column to arrange and properly join the data
  df <- data %>% 
    rowid_to_column()
  
  edited_text <- map(columns,
                     function(col) {
                       # check for instances of the email pattern in the specified column...
                       # to do this we have to create a generic column name from the
                       # specified column name and then filter on the generic name
                       replace_df <- df %>% 
                         rename(select_col = {{ col }})
                       emails <- replace_df %>% 
                         filter(grepl(email_pat, select_col))
                       # and where there are not
                       no_emails <- replace_df %>% 
                         filter(!rowid %in% emails$rowid) 
                       # substitute ` xxxx` for the characters before the `@` sign, retaining all 
                       # other text
                       emails <- emails %>% 
                         rowwise() %>% 
                         mutate(select_col = gsub(
                           pattern = email_pat, 
                           replacement = paste0(
                             " xxxx",
                             str_extract(
                               string = select_col, 
                               pattern = "\\s*[a-zA-Z0-9.-]+[\\.,][a-zA-Z]{2,}")
                           ), 
                           x = select_col)) %>% 
                         ungroup()
                       # format and join back to the no email subset
                       replace_df <- full_join(emails, no_emails) 
                       
                       # check for instances of the phone pattern in the specified column...
                       # grab the instances where there are phone numbers
                       phones <- replace_df %>% 
                         filter(grepl(phone_pat, select_col))
                       # and where there are not
                       no_phones <- replace_df %>% 
                         filter(!rowid %in% phones$rowid)
                       # and assign the new text to the specified column
                       phones <- phones %>% 
                         rowwise() %>% 
                         mutate(select_col = gsub(pattern = phone_pat, 
                                                  replacement = "xxxxxxxxxx", 
                                                  x = select_col)) %>% 
                         ungroup()
                       # format and join back to the no phone number subset
                       replace_df <- full_join(phones, no_phones)
                       
                       replace_df %>% 
                         rename({{ col }} := select_col) %>% 
                         select(rowid, {{ col }})
                     }) %>% 
    reduce(., full_join)
  
  anonymized_df <- df %>% 
    select(-all_of(columns)) %>% 
    left_join(., edited_text) %>% 
    select(-rowid)
  
  # return the dataframe as long as it's the same shape!
  if (nrow(data) == nrow(anonymized_df) & ncol(data) == ncol(anonymized_df)) {
    return(anonymized_df)
  } else {
    print("Something went wrong, the input data frame and output data frame
          are not the same shape.")
  }
}
