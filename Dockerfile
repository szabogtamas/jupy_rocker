FROM rocker/rstudio:4.0.4

RUN sudo apt-get update -y
RUN sudo apt-get install -y python3-pip

RUN pip3 install jupyter -U
RUN pip3 install jupyterlab

ADD ./.Rprofile /home/rstudio/.config/rstudio/.Rprofile
ADD ./rstudio-prefs.json /home/rstudio/.config/rstudio/rstudio-prefs.json
RUN chmod a+rwx -R /home/rstudio
ENV R_PROFILE_USER /home/rstudio/.config/rstudio/.Rprofile

RUN mkdir -p /etc/services.d/jupyter
RUN  echo '#!/bin/bash \
  \n jupyter lab --ip=0.0.0.0 --allow-root' \
  > /etc/services.d/jupyter/run
RUN  echo '#!/bin/bash \
  \n jupyter stop 8989' \
  > /etc/services.d/jupyter/finish

EXPOSE 8989

CMD ["/init"]
