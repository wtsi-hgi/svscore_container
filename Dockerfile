FROM mambaorg/micromamba:0.15.3

# apt installs
USER root
# nuke cache dirs before installing pkgs; tip from Dirk E fixes broken img
RUN rm -f /var/lib/dpkg/available && rm -rf  /var/cache/apt/*
RUN apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y --no-install-recommends \
  procps \
  python2.7 \
  build-essential curl git python3-pip procps wget \ 
  manpages-dev g++ gcc gfortran make autoconf automake libtool \
  zlib1g-dev liblzma-dev libbz2-dev lbzip2 libgsl-dev \
  libblas-dev libx11-dev \
  libreadline-dev libxt-dev libpcre2-dev libcurl4-openssl-dev \
  && rm -rf /var/lib/apt/lists/*

# install mamba env
USER micromamba
COPY --chown=micromamba:micromamba environment.yml /tmp/env.yaml
RUN micromamba install -y -n base -f /tmp/env.yaml && \
    micromamba clean --all --yes

USER root
RUN rm /usr/bin/perl
RUN ln -s /opt/conda/bin/perl /usr/bin/perl

USER micromamba
RUN wget -c https://github.com/lganel/SVScore/archive/refs/tags/v0.6.tar.gz  -O - | tar -xz
RUN mv SVScore-0.6/* /opt/conda/bin/

RUN svscore.pl --version

RUN vcfanno >/opt/conda/conda_software_versions.txt 2>&1
RUN perl --version >> /opt/conda/conda_software_versions.txt
RUN tabix --version >> /opt/conda/conda_software_versions.txt
RUN bgzip --version >> /opt/conda/conda_software_versions.txt
RUN svtools --version >> /opt/conda/conda_software_versions.txt  2>&1
RUN svscore.pl --version >> /opt/conda/conda_software_versions.txt
RUN generateannotations.pl --version >> /opt/conda/conda_software_versions.txt
RUN cat /opt/conda/conda_software_versions.txt

USER micromamba
WORKDIR /tmp
ENTRYPOINT ["/bin/entrypoint.sh"]
CMD ["/bin/bash"]