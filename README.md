
This directory has the code needed to replicate the results in
"Quantifying population contact patterns in the United States during the COVID-19 pandemic"


* `code/` - has the code used in the analysis
* `data/` - has the survey data used in the analysis
            (NOTE: because of its size, this is not included in the git repo)
* `out/`  - where the results of the scripts get saved (this is also not included in the git repo; it gets created by the scripts)

## DATA

We provide data from the surveys we conducted. To replicate the results in our paper,
you will also need to download data from 

The data we provide are

* data/
	- df_all_waves.rds - the survey responses 
	- df_boot_all_waves.rds - bootstrap weights to accompany df_all_waves.rds
	- df_alters_all_waves.rds - file with info about detailed contacts reported by respondentts
	- df_alters_boot_all_waves.rds - bootstrap weights to accompany df_alters_all_waves.rds
* data/ACS
	- acs15_fb_agecat.rds - total number of people in the US in 2015 by age categories used in FB survey
	- acs15_wave0_agecat.rds - total number of people in the US in 2015 by age cateogries used in our survey
	- acs18_wave0_agecat.rds - total number of people in the US in 2018 by age categories used in our survey
	- acs18_national_targets.rds - distribution of 2018 US population by covariates that we use in calibration weighting
	- acs18_wave1_agecat_withkids.rds - total number of people in the US in 2018 by age categories that include children
* data/fb-2015-svy
	- fb_ego.csv - survey responses
	- fb_alters.csv - detailed contacts reported in survey
	- fb_bootstrapped_weights.csv - bootstrap weights to accompany fb_ego.csv
* data/prem_contact_matrix
	- prem_usa.csv - MUST BE DOWNLOADED BY YOU: see below 
* data/polymod
	- [this directory starts empty, but has files generated in it by the scripts]

Prem data - before running the code, you must download this file from TODO

## CODE

These scripts were run on a 2020 Macbook Pro with 8 cores and 64 GB of memory.
Because of the large number of bootstrap resamples, some of the files take time to run.
We try to give a rough sense for expected runtime below.

* 01-prep-wave-comparison-model - this prepares a dataset that is later used in the models
* 10-compare-waves - this file analyzes the sample composition and marginal distributions of number of contacts, relationship, and location of contacts [this takes about 90 minutes to run]
* 11-sensitivity - this file assesses the sensitivity of results to including / not including physical contact in Waves 1 and 2 [this takes about 100 minutes to run]
* 12-model_mean_perwave - this model estimates average number of contacts, accounting for censoring, using a model
* 21-allcc_nb_censored_loaded_weighted - this is the model for non-household contacts
* 22-nonhhcc_nb_censored_loaded_weighted - this is the model for all contacts
* 23-plot_model_coefficients - this makes a plot comparing the coefficient estimates from the non-hh and all contacts models
* 31-estimate_R0 - this uses the contact matrices to estimate R0, and plots the contact matrices
* 32-estimate_R0_onlycc - this does the same as the previous file, but only for non-physical contacts (as a sensitivity analysis)


## DOCKER

It is likely that you have different versions of R and specific R packages than we did
when we wrote our code.  Thus, we recommend using Docker to replicate our results. 
Using Docker will ensure that you have exactly the same computing environment that we did
when we conducted our analyses.

To use Docker

1. [Install Docker Desktop](https://www.docker.com/get-started) (if you don't already have it)
1. Clone this repository 
1. TODO - instructions for copying data into data/ directory
1. Be sure that your current working directory is the one that you downloaded the repository into. It's probably called bics-paper-code/
1. Build the docker image. 
	docker build --rm -t bics-replication .
   This step will likely take a little time, as Docker builds your image (including installing various R packages)
1. Run the docker image
	docker run -d --rm -p 8888:8787 -e PASSWORD=pass --name bics bics-replication
1. Open a web browser and point it to localhost:8888
1. Log onto Rstudio with username 'rstudio' and password 'pass'
1. Download the zipped data:
	piggyback::pb_download(file="data.zip", repo="dfeehan/bics-piggyback-test", tag="v0.0.1", dest="bics-paper/bics-paper-code/")
1. Unzip data.zip:
	unzip("bics-paper/bics-paper-code/data.zip", exdir="bics-paper/bics-paper-code")
1. Run the files in the order described above


TODO

- make clean directory (clean out all paper stuff, etc)
- remove/ignore .html files
- make a file that runs all of the code
- figure out how to sync output to container?
- run everything start to finish
- also upload everything to dataverse



