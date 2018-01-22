FROM rocker/shiny

MAINTAINER matthew.emery44@gmail.com

RUN apt-get update --fix-missing && apt-get install -y wget \
 apt-utils \
 apt-transport-https \
 bzip2 \
 ca-certificates \
 gnupg \
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

RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
sudo apt-get update && sudo apt-get install -y google-cloud-sdk \
 google-cloud-sdk-app-engine-python

RUN R -e "install.packages('devtools', repos='https://cran.rstudio.com/')"

RUN R -e "devtools::install_github('davidklaing/vizit/r-package')"

ADD environment.yml /

RUN conda env create -f environment.yml

CMD ["/usr/bin/shiny-server.sh"]
