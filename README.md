# jupy_rocker
A Rocker RStudio image supercharged with Jupyter Lab

## Usage
* Pull the image with `docker pull szabogtamas/jupy_rocker:latest`
* Fire up the container issuing `docker run --rm -p 127.0.0.1:8787:8787 -p 127.0.0.1:8989:8989 -v $PWD:/home/rstudio/local_files -e USERID=$UID szabogtamas/jupy_rocker:latest`
* Run RStudio the usual way pointing a browser to `localhost:8787`
* Or open Jupyter Lab by navigaitng to `localhost:8989/lab
