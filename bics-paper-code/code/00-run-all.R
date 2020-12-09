
root.dir <- "bics-paper-release"

## Download data
piggyback::pb_download(file="data.zip", 
		       repo="dfeehan/bics-piggyback-test", 
		       tag="v0.0.1", 
		       dest=file.path(root.dir, "bics-paper-code"))

## Unzip data
unzip(file.path(root.dir, "bics-paper-code", "data.zip"), 
      exdir=file.path(root.dir, "bics-paper-code"))

## Run all of the scripts
rmd_files <- list.files(path=file.path(root.dir, "bics-paper-code", "code"), pattern=".Rmd")

for (cur_file in rmd_files) {
	  cat("Running ", cur_file, "\n")
  rmarkdown::render(file.path(root.dir, "bics-paper-code", "code", cur_file))
}

