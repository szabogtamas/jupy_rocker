FROM rocker/rstudio:4.0.4

ADD ./configs/rstudio/.Rprofile /home/rstudio/.config/rstudio/.Rprofile
ADD ./configs/rstudio/rstudio-prefs.json /home/rstudio/.config/rstudio/rstudio-prefs.json
RUN chmod a+rwx -R /home/rstudio
ENV R_PROFILE_USER /home/rstudio/.config/rstudio/.Rprofile

ENV ADD shiny
RUN wget -O /etc/cont-init.d/add https://github.com/rocker-org/rocker-versioned/blob/dff37a27698cfe8cda894845fa194ecb5f668d84/rstudio/add_shiny.sh
RUN bash /etc/cont-init.d/add

RUN sudo apt-get update -y
RUN sudo apt-get install -y python3-pip

RUN pip3 install jupyter -U
RUN pip3 install jupyterlab

ADD ./configs/jupyter/jupyter_lab_config.py /root/.jupyter/jupyter_lab_config.py
RUN chmod +x /root/.jupyter/jupyter_lab_config.py

RUN mkdir -p /etc/services.d/jupyter
RUN echo '#!/bin/bash \
  \n cd /home/rstudio \
  \n jupyter lab --ip=0.0.0.0 --port=8989 --allow-root' \
  > /etc/services.d/jupyter/run
RUN echo '#!/bin/bash \
  \n kill -TERM -$$' \
  #\n jupyter stop 8989' \
  > /etc/services.d/jupyter/finish

EXPOSE 8989

CMD ["/init"]
