# AquaMatch_download_WQP

This repository is covered by the MIT use license. We request that all downstream uses of this work be available to the public when possible.

### Background

This repository is one part of an expansion and update of the original [AquaSat](https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2019WR024883) product, a dataset of \~600k coincident field and satellite matchups across four parameters: total suspended solids (TSS), dissolved organic carbon (DOC), chlorophyll-*a* (chla), and Secchi disc depth (SDD). The updated product, **AquaMatch**, expands the number of parameters of *in situ* data included in the matching process, adds tiers describing data quality, and adds new satellites and spectral bands. This project repository, AquaMatch_download_WQP, contains the first step in the AquaMatch process: a workflow that inventories and downloads *in-situ* data from the [Water Quality Portal (WQP)](waterqualitydata.us/). The second step of the process is contained in another repository, [AquaMatch_harmonize_WQP](https://github.com/ROSSyndicate/AquaMatch_harmonize_WQP), which contains the harmonization workflow for the WQP data following its download.

Download is separated from harmonization to create stable snapshots of the WQP download and increase reproducibility for the harmonization process. The WQP is constantly changing, and even given specific parameters and date ranges, two downloads from the WQP are unlikely to be the same because data providers may add or remove data at any point in time.

### Technical details

#### Workflow

AquaSat v2 uses the {targets} workflow management R package to reimagine the [original AquaSat codebase](https://github.com/GlobalHydrologyLab/AquaSat). The framework for this workflow is based on code adapted from [this USGS pipeline](https://github.com/USGS-R/ds-pipelines-targets-example-wqp) and has been further developed by members of the [ROSSyndicate](https://github.com/rossyndicate).

Technical details on {targets} workflows are available in the [{targets} User Manual](https://books.ropensci.org/targets/). {targets} workflows are built upon lists of "targets", which can be thought of as analytical steps written out in code. This workflow uses a targets list spread across multiple scripts in an effort to facilitate organization of the code. `_targets.R` serves as the main list of targets and references the other lists of targets, which are defined inside `1_inventory.R` and `2_download.R`.

#### Setup

Users will need to authorize the [{googledrive}](https://googledrive.tidyverse.org/index.html) R package. This workflow requires {googledrive} in order to store WQP downloads. Be sure to authorize a Google account to use for online storage when running this workflow. Information on authorization can be found [here](https://googledrive.tidyverse.org/reference/drive_auth.html). The `run.R` script is set up to assume that an account has already been authorized on the user's computer.

#### Organization and documentation

In general, `src/` folders in this repository contain source code for customized functions used by the {targets} pipeline. The numbered R scripts have functions defined in their respective folders (e.g., `1_inventory/src/`, etc.).

Documentation of the entire AquaMatch process from download to harmonization is available in the form of a {bookdown} document in the second repository, [AquaMatch_harmonize_WQP](https://github.com/ROSSyndicate/AquaMatch_harmonize_WQP).

If the `run.R` script has been used to generate the current pipeline version, you can find an html file with the current network diagram for the pipeline in `docs/current_visnetwork.html`.
