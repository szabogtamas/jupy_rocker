FROM rocker/rstudio:4.0.4

# Adding shiny to image, not just conditionally

RUN sudo apt-get update -y
RUN sudo apt-get install -y gdebi-core
RUN sudo apt-get install -y libxt-dev
RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb
RUN install2.r -e --skipinstalled shiny rmarkdown tidyr dplyr
RUN cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/ && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/log/shiny-server && \
    chown shiny.shiny /var/log/shiny-server
RUN mkdir -p /etc/services.d/shiny-server
RUN echo '#!/bin/bash \
  \n exec shiny-server > /var/log/shiny-server.log' \
  > /etc/services.d/shiny-server/run
RUN adduser rstudio shiny

# Fine-tuning configs for RStudio

ADD ./configs/rstudio/rstudio-prefs.json /home/rstudio/.config/rstudio/rstudio-prefs.json
ADD ./configs/rstudio/.Rprofile /home/rstudio/.config/rstudio/.Rprofile
RUN sed -i '4 i export R_PROFILE_USER="/home/rstudio/.config/rstudio/.Rprofile" > /dev/null' /etc/services.d/rstudio/run
RUN chmod a+rwx -R /home/rstudio

# Add Jupyter as well

RUN sudo apt-get update -y
RUN sudo apt-get install -y python3-pip
RUN pip3 install jupyter -U
RUN pip3 install jupyterlab
RUN pip3 install jupyterthemes

ADD ./configs/jupyter/config.json /home/rstudio/.jupyter/config.json

RUN mkdir -p /etc/services.d/jupyter
RUN echo '#!/bin/bash \
  \n cd /home/rstudio \
  \n /usr/local/bin/jupyter lab --ip=0.0.0.0 --port=8989 --allow-root --config=/home/rstudio/.jupyter/config.json' \
  > /etc/services.d/jupyter/run
RUN echo '#!/bin/bash \
  \n jupyter stop 8989' \
  > /etc/services.d/jupyter/finish

ENV PATH=/usr/local/bin:$PATH

EXPOSE 8989

CMD ["/init"]
