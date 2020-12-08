FROM rocker/verse:4.0.2

# copy working files over
COPY . /home/rstudio/bics-paper-release

# install dependencies described in DESCRIPTION file
RUN Rscript -e "devtools::install_deps('/home/rstudio/bics-paper-release')"

RUN touch /home/rstudio/bics-paper-release/.here

RUN chown -R rstudio /home/rstudio





