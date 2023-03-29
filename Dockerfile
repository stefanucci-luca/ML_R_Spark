FROM ubuntu:20.04

## System settings
LABEL maintainer="ls31@sanger.ac.ukuk"
ARG DEBIAN_FRONTEND=noninteractive
# ARG R_VERSION='4.1.2-1.1804.0'
# ARG nlme_ver='3.1.155-1.1804.0'
# ARG mass_ver='7.3-55-1.1804.0'
# ARG class_ver='7.3-20-1.1804.0'
# ARG nnet_ver='7.3-17-1.1804.0'
ARG LIBARROW_BINARY="true"
ARG RSPM_CHECKPOINT=2696074
ARG CRAN="https://packagemanager.rstudio.com/all/__linux__/focal/${RSPM_CHECKPOINT}"

USER root

# Install required packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        software-properties-common \
        wget \
        gdebi-core \
        libclang-dev \
        psmisc \
        libcurl4-openssl-dev \
        libssl-dev \
        libxml2-dev \
        libgit2-dev \
        libpng-dev \
        libudunits2-dev \
        libxkbcommon-x11-0 \
        libgdal-dev \
        libproj-dev \
        default-jdk \
        libicu-dev \
        libbz2-dev \
        liblzma-dev \
        openjdk-8-jdk \
        python3.9 \
        python3-pip \
        git \
        jq \
        libmagick++-dev \
        libpq-dev \
        libsecret-1-dev \
        libsodium-dev \
        ssh \
        build-essential \
        libgpgme11-dev \
        libseccomp-dev \
        golang \
        uuid-dev \
        curl \
        unzip \
        gzip \
        sudo \
        software-properties-common \
        dirmngr 

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        r-base \
        r-base-dev \
        r-base-core \
        r-recommended \
        r-cran-mass \
        r-cran-class \
        r-cran-nnet \
        r-recommended \
        r-cran-nlme \ 
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Rstudio
RUN wget https://download1.rstudio.org/desktop/bionic/amd64/rstudio-2021.09.1-372-amd64.deb
RUN gdebi --non-interactive rstudio-2021.09.1-372-amd64.deb

# Install RStudio Server
RUN wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.4.1106-amd64.deb
RUN gdebi --non-interactive rstudio-server-1.4.1106-amd64.deb 

# Install Sparklyr and dependencies
RUN R -e "install.packages(c('sparklyr', 'dplyr', 'DBI', 'rJava', 'readr', 'knitr', 'rmarkdown'), repos='http://cran.us.r-project.org')"
RUN R -e "sparklyr::spark_install(version = '3.2')"
# Install R packages
RUN Rscript -e 'install.packages(c("rag","tidyverse", "tidymodels", "littler", "docopt", "broom", "remotes"), dependencies = TRUE)'
RUN Rscript -e 'install.packages(c("arrow", "lemon", "AzureStor", "nycflights13", "Lahman", "renv", "devtools"), dependencies = TRUE)'
RUN Rscript -e 'install.packages(c("bigQueryR", "bigrquery", "googleCloudStorageR", "data.table"), dependencies = TRUE)'
RUN Rscript -e 'install.packages(c("rstan","rsparkling","h2o"), dependencies = TRUE)'
RUN Rscript -e 'install.packages(c("keras","tensorflow"), dependencies = TRUE)'


# Install Apache Spark
RUN wget https://archive.apache.org/dist/spark/spark-3.2.0/spark-3.2.0-bin-hadoop3.2.tgz && \
    tar -xzf spark-3.2.0-bin-hadoop3.2.tgz && \
    rm spark-3.2.0-bin-hadoop3.2.tgz && \
    mv spark-3.2.0-bin-hadoop3.2 /usr/local/spark

# Set environment variables
ENV SPARK_HOME=/usr/local/spark
ENV PATH="$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${SPARK_HOME}/bin"

RUN mkdir -p /usr/local/spark/R
COPY *.R /usr/local/spark/R

RUN pip3 install numpy pandas Cython requests pandas-io 
RUN pip3 install fastparquet 
RUN pip3 install "dask[complete]"  
