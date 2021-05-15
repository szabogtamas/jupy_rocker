FROM rocker/rstudio:4.0.4

# Fine-tuning configs for RStudio

ADD ./configs/rstudio/.Rprofile /home/rstudio/.config/rstudio/.Rprofile
ADD ./configs/rstudio/rstudio-prefs.json /home/rstudio/.config/rstudio/rstudio-prefs.json
RUN chmod a+rwx -R /home/rstudio
ENV R_PROFILE_USER /home/rstudio/.config/rstudio/.Rprofile

# Adding shiny to image, not just conditionally

RUN sudo apt-get update -y
RUN sudo apt-get install -y gdebi-core
RUN sudo apt-get install -y libxt-dev
RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb
RUN install2.r -e --skipinstalled shiny rmarkdown
RUN cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/ && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/log/shiny-server && \
    chown shiny.shiny /var/log/shiny-server
RUN mkdir -p /etc/services.d/shiny-server
RUN echo '#!/bin/bash \
  \n exec shiny-server > /var/log/shiny-server.log' \
  > /etc/services.d/shiny-server/run
RUN adduser rstudio shiny

# Add Jupyter as well

RUN sudo apt-get update -y
RUN sudo apt-get install -y python3-pip
RUN pip3 install jupyter -U
RUN pip3 install jupyterlab

ADD ./configs/jupyter/jupyter_lab_config.py /root/.jupyter/jupyter_lab_config.py
RUN chmod +x /root/.jupyter/jupyter_lab_config.py

RUN mkdir -p /etc/services.d/jupyter
RUN echo '#!/bin/bash \
  \n cd /home/rstudio \
  \n /usr/local/bin/jupyter lab --ip=0.0.0.0 --port=8989 --allow-root' \
  > /etc/services.d/jupyter/run
RUN echo '#!/bin/bash \
  \n kill -TERM -$$' \
  > /etc/services.d/jupyter/finish

EXPOSE 8989

CMD ["/init"]
