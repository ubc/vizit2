FROM rocker/shiny

MAINTAINER matthew.emery44@gmail.com

RUN apt-get update --fix-missing && apt-get install -y wget \
 bzip2 \
 ca-certificates \
 libglib2.0-0 \
 libxext6 \
 libsm6 \
 libxrender1 \
 git \
 mercurial \
 subversion \
 libssl-dev \
 libxml2-dev \
 libgsl0-dev \
 curl \
 grep \
 sed \
 dpkg

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-4.3.14-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
rm ~/miniconda.sh

RUN TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

ENV PATH /opt/conda/bin:$PATH

RUN curl https://sdk.cloud.google.com | bash

RUN R -e "install.packages(c('devtools'), repos='https://cran.rstudio.com/')"

RUN R -e "devtools::install_github('alim1990/mooc_capstone_private/r-package', host = 'https://github.ubc.ca/api/v3')"

CMD ["/usr/bin/shiny-server.sh"]