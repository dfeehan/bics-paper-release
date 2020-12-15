
con <- file("run_all.log")
sink(con, append=TRUE, split=TRUE)
sink(con, append=TRUE, type="message", split=TRUE)

root.dir <- "bics-paper-release"

## Download data
piggyback::pb_download(file="data.zip", 
		       repo="dfeehan/bics-paper-release", 
		       tag="v0.0.1", 
		       dest=file.path(root.dir, "bics-paper-code"))

## Unzip data
unzip(file.path(root.dir, "bics-paper-code", "data.zip"), 
      exdir=file.path(root.dir, "bics-paper-code"))

## Run all of the scripts
rmd_files <- list.files(path=file.path(root.dir, "bics-paper-code", "code"), pattern=".Rmd")

for (cur_file in rmd_files) {
	cat("================================\n")
	tictoc::tic(glue::glue("Running {cur_file}"))
	cat("Running ", cur_file, "\n")
  	rmarkdown::render(file.path(root.dir, "bics-paper-code", "code", cur_file))
  	tictoc::toc()
	cat("================================\n")
}

sink() 
sink(type="message")
