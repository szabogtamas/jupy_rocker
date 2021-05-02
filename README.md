# jupy_rocker
A Rocker RStudio image supercharged with Jupyter Lab

## Usage
* Pull the image with `docker pull szabogtamas/jupy_rocker:latest`
* Fire up the container issuing
```
docker run --rm \
  -p 127.0.0.1:8989:8989 -p 127.0.0.1:8787:8787 -p 127.0.0.1:3838:3838 \
  -v $PWD:/home/rstudio/local_files \
  -e USERID=$UID -e PASSWORD=<password> \
  szabogtamas/jupy_rocker
```
* Open Jupyter Lab by navigaitng to `localhost:8989/lab`
* Or run RStudio the usual way pointing a browser to `localhost:8787`
* Shiny can be accessed at `localhost:3838`

Please note that this image is intended to be a base for other projects. Both Jupyter and RStudio is missing many important data analysis / visualization packages.  
Individual projects will benefit from installing plotly, seaborn, pandas, etc om top of this image.
