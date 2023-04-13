# ML_R_Spark

This repo has the info relative to set an OpenStack VM cluster for Hadoop work.

The first thing I did was to create a Docke container with Rserver - sparklyr and a few packages.

The image was based on rocker Rstudio release and edited (According to the dockerfile in this repo) to allow the correct softwares in the docker image. To replicate, rebuild or add new features to the image one should clone the rocker git repo from `https://github.com/rocker-org/rocker-versioned2` and edit the Dockerfile in there.


