FROM rocker/r-ver:4.1.0

LABEL org.opencontainers.image.licenses="GPL-2.0-or-later" \
      org.opencontainers.image.source="https://github.com/rocker-org/rocker-versioned2" \
      org.opencontainers.image.vendor="Rocker Project" \
      org.opencontainers.image.authors="Carl Boettiger <cboettig@ropensci.org>"

ENV S6_VERSION=v2.1.0.2
ENV RSTUDIO_VERSION=2022.02.3+492
ENV DEFAULT_USER=rstudio
ENV PANDOC_VERSION=default
ENV CTAN_REPO=https://www.texlive.info/tlnet-archive/2022/10/30/tlnet

# Install OpenJDK-8
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y ant && \
    apt-get clean;
    
# Fix certificate issues
RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

RUN /rocker_scripts/install_rstudio.sh
RUN /rocker_scripts/install_pandoc.sh
RUN /rocker_scripts/install_verse.sh
RUN /rocker_scripts/install_tidyverse.sh

EXPOSE 8787

# Install R packages
RUN install2.r --error \
      sparklyr \
      dplyr \
      DBI \
      rJava \
      readr \
      knitr \
      rmarkdown \
      # rag \ 
      tidymodels \
      littler \
      docopt \ 
      broom \ 
      remotes \
      arrow \
      lemon \
      AzureStor \
      nycflights13 \
      Lahman \
      renv \
      devtools \
      bigQueryR \
      bigrquery \
      googleCloudStorageR \
      data.table \ 
      rstan \
      rsparkling \
      h2o \
      keras \
      tensorflow \
      RPostgres \ 
      RSQLite \
      fst \
      shiny \
      gert \
      vroom \
      dbplyr \
      dtplyr \
      duckdb \
      sparkxgb \
      ggraph \
      igraph \
      sparktf \
      tfdatasets \
      variantspark \
      magrittr \
      tidyr \
      broom.mixed \
      BiocManager

# Install biocanductor Pakcages
RUN R -e "BiocManager::install(c('biomaRt', 'AnnotationHub', 'GenomicRanges'))"

# Install Apache Spark
RUN wget https://archive.apache.org/dist/spark/spark-3.2.0/spark-3.2.0-bin-hadoop3.2.tgz && \
    tar -xzf spark-3.2.0-bin-hadoop3.2.tgz && \
    rm spark-3.2.0-bin-hadoop3.2.tgz && \
    mv spark-3.2.0-bin-hadoop3.2 /usr/local/spark

# Set environment variables for SPARK
ENV SPARK_HOME=/usr/local/spark
ENV PATH="$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${SPARK_HOME}/bin"


CMD ["/init"]
