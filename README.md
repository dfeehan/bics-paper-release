
This directory has the code needed to replicate the results in
"Quantifying population contact patterns in the United States during the COVID-19 pandemic"


* `code/` - has the code used in the analysis
* `data/` - [will be created by a script] has the survey data used in the analysis
            (NOTE: because of its size, the data are not included in the git repo; they will be downloaded by the script 00-run-all.r)
* `out/`  - [will be created by a script] where the results of the scripts get saved (this is also not included in the git repo; it gets created by the scripts)

## DATA

We provide data from the surveys we conducted.  To replicate our comparison
with the contact matrix from Prem et al (2017), you will need to follow the
instructions below.

The data we provide are

* `data/`
	- `df_all_waves.rds` - the survey responses 
	- `df_boot_all_waves.rds` - bootstrap weights to accompany df_all_waves.rds
	- `df_alters_all_waves.rds` - file with info about detailed contacts reported by respondentts
	- `df_alters_boot_all_waves.rds` - bootstrap weights to accompany df_alters_all_waves.rds
* `data/ACS`
	- `acs15_fb_agecat.rds` - total number of people in the US in 2015 by age categories used in FB survey
	- `acs15_wave0_agecat.rds` - total number of people in the US in 2015 by age cateogries used in our survey
	- `acs18_wave0_agecat.rds` - total number of people in the US in 2018 by age categories used in our survey
	- `acs18_national_targets.rds` - distribution of 2018 US population by covariates that we use in calibration weighting
	- `acs18_wave1_agecat_withkids.rds` - total number of people in the US in 2018 by age categories that include children
* `data/fb-2015-svy`
	- `fb_ego.csv` - survey responses
	- `fb_alters.csv` - detailed contacts reported in survey
	- `fb_bootstrapped_weights.csv` - bootstrap weights to accompany fb_ego.csv
* `data/prem_contact_matrix`
	- `prem_usa.csv` - estimated contact matrix for the United States from [Prem *et al.* (2017)](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1005697). **NOTE**: This data must be downloaded by you. See instructions below.
* `data/polymod`
	- [this directory starts empty, but has files generated in it by the scripts]

Data from Prem *et al.* (2017) - You must download this data from [here](https://doi.org/10.1371/journal.pcbi.1005697.s002). The contact matrix for the US (for all locations) is available in a tab in the `MUestimates_all_locations_2.xlsx` file in the downloaded folder. Save this tab as a `csv` file with the name `prem_usa.csv` in the `prem_contact_matrix` subfolder in the `data` folder.

NOTE: The first time you run `00-run-all.R` (see below), the last script (`35-sensitivity-compare-with-Prem-matrix.Rmd`) will stop with an error because it can't find the `prem_usa.csv` datafile. Once you create this file following the above instructions, you will be able to run `00-run-all.R` without any errors. 

## CODE

These scripts were run on a 2020 Macbook Pro with 8 cores and 64 GB of memory.
Because of the large number of bootstrap resamples, some of the files take time to run.
We try to give a rough sense for expected runtime below.

* `00-run-all.R` - this file downloads the data and runs all of the scripts
* `01-prep-wave-comparison-model` - this prepares a dataset that is later used in the models
* `10-compare-waves` - this file analyzes the sample composition and marginal distributions of number of contacts, relationship, and location of contacts [this takes about TODO minutes to run]
* `11-relationships` - TODO 
* `12-locations` - TODO 
* `13-figure` - TODO 
* `14-sensitivity` - this file assesses the sensitivity of results to including / not including physical contact in Waves 1 and 2 [this takes about TODO minutes to run]
* `15-avg-contacts` - TODO 
* `12-model_mean_perwave` - this model estimates average number of contacts, accounting for censoring, using a model
* `21-allcc_nb_censored_loaded_weighted` - this is the model for non-household contacts
* `22-nonhhcc_nb_censored_loaded_weighted` - this is the model for all contacts
* `23-plot_model_predictions_by_covars` - TODO 
* `30-contact-matrices` - TODO 
* `31-prep-estimate-R0-bootstrap` - this prepares the dataset that is used for the epidemiological analyses
* `32-estimate-R0` - this file generates age-structured contact matrices from the survey data and the corresponding R<sub>0</sub> estimates 
* `33-sensitivity-estimate-R0-onlycc` - this file assesses the sensitivity of the R<sub>0</sub> estimates  to including / not including physical contact in Waves 1 and 2
* `34-sensitivity-high-low-baselineR0` - this file assesses the sensitivity of the R<sub>0</sub> estimates  to assuming higher and lower baseline values
* `35-sensitivity-compare-with-Prem-matrix.Rmd` - this file compares the data from Feehan and Cobb (2019) with estimates from Prem *et al.* (2017) and the UK POLYMOD data from Mossong *et al.* (2008)

Additionally, there are two files that have some miscellaneous helper functions:

* `model-coef-plot-helpers.R`
* `utils.R`


## DOCKER

It is likely that you have different versions of R and specific R packages than we did
when we wrote our code.  Thus, we recommend using Docker to replicate our results. 
Using Docker will ensure that you have exactly the same computing environment that we did
when we conducted our analyses.

To use Docker

1. [Install Docker Desktop](https://www.docker.com/get-started) (if you don't already have it)
1. Clone this repository 
1. Be sure that your current working directory is the one that you downloaded the repository into. It's probably called `bics-paper-code/`
1. Build the docker image. 
	`docker build --rm -t bics-replication .`
   This step will likely take a little time, as Docker builds your image (including installing various R packages)
1. Run the docker image
	`docker run -d --rm -p 8888:8787 -e PASSWORD=pass --name bics bics-replication`
1. Open a web browser and point it to localhost:8888
1. Log onto Rstudio with username 'rstudio' and password 'pass'
1. Open the file `bics-paper-code/code/00-run-all.r`
1. Running the file should replicate everything. If you have not downloaded the Prem *et al* (2017) data, the last script (`35-sensitivity-compare-with-Prem-matrix.Rmd`) will stop with an error because it can't find the `prem_usa.csv` datafile.

