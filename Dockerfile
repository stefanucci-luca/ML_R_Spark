FROM rocker/r-ver:4.2.0

LABEL org.opencontainers.image.licenses="GPL-2.0-or-later" \
      org.opencontainers.image.source="https://github.com/rocker-org/rocker-versioned2" \
      org.opencontainers.image.vendor="Rocker Project" \
      org.opencontainers.image.authors="Carl Boettiger <cboettig@ropensci.org>"

ENV S6_VERSION=v2.1.0.2
ENV RSTUDIO_VERSION=2022.02.3+492
ENV DEFAULT_USER=ls31
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

# install archived dependencies
RUN R -e "install.packages(pkgs='http://cran.nexr.com/src/contrib/speedglm_0.3-2.tar.gz', type='source', repos=NULL)"
RUN R -e "install.packages(c('network', 'sna', 'ergm', 'coda', 'ROCR', 'statnet.common'))"
RUN R -e "install.packages(pkgs='https://cran.r-project.org/src/contrib/Archive/btergm/btergm_1.10.6.tar.gz', type='source', repos=NULL)"

# Fro some weird reason rstan and other packeage fails id run in the followinf command, becasue of the cran and otehr references
# Install R packages
RUN install2.r \
    --error \
    --deps TRUE \
    rstan \
    rstanarm \
    rJava \ 
    ### <- this packege probably failed error: unable to load shared object '/usr/local/lib/R/site-library/rJava/libs/rJava.so':
            # libjvm.so: cannot open shared object file: No such file or directory
    xlsx \
    # adam \
    # auto_adam \
    # auto_arima \
    # arima \
    # arima_xgboost \
    # auto_arima_xgboost \
    # brulee \
    # stan_glmer \
    glmnet 
    
# Install R packages
RUN install2.r --error \
    # --deps TRUE \
    -n 5 \
    -r 'http://cran.rstudio.com' \
    # -r 'http://glmmadmb.r-forge.r-project.org/repos' \
    -r 'http://www.bioconductor.org/packages/release/bioc' \
      sparklyr \
      dplyr \
      DBI \
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
      BiocManager \
      RNOmni \
      janitor \
      rjson \
      markdown \
      bayestestR \
      loo \
      tidybayes \
      bayesplot \
      posterior \
      caret \
      dbplot \
      yardstick \
      BayesFactor \
      lme4 \
      remotes \
      selectr \
      caTools \
      randomForest \
      ranger \
      gap \
      vip \
      pdp \
      xgboost \
      # h2o_gbm \
      rpart \
      dbarts \
      flexsurv \
      survival \
      klaR \
      naivebayes \
      kernlab \
      kknn \
      mixOmics \
      # nnetar \
      tidypredict \
      multidplyr 

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

# Install python and Keras related (adapted from https://github.com/ivanvanderbyl/tensorflow-keras-docker/blob/master/Dockerfile)
# Pick up some TF dependencies
RUN apt-get update && apt-get install -y \
        curl \
        libfreetype6-dev \
        libpng-dev \
        libzmq3-dev \
        pkg-config \
        python3.8 \
        python-numpy \
        python3-pip \
        python3-scipy \
        git \
        libhdf5-dev \
        graphviz \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 --no-cache-dir install \
        ipykernel \
        jupyter \
        numpy==1.22 \
        matplotlib \
        h5py \
        pydot-ng \
        graphviz \
        tensorflow \
        keras \
        Theano \ 
        ipykernel 

CMD ["/init"]
