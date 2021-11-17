FROM ubuntu:22.04

# apt installs
# nuke cache dirs before installing pkgs
RUN rm -f /var/lib/dpkg/available && rm -rf  /var/cache/apt/*
RUN apt update && apt upgrade -y
RUN apt install software-properties-common -y
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt install -y \
        python2.7 python2.7-dev \
        perl cpanminus \
        procps git wget curl tree \
        tabix \
        g++ gcc gfortran make \
        zlib1g-dev liblzma-dev libbz2-dev lbzip2 libgsl-dev \
        libblas-dev libx11-dev libtool libreadline-dev libxt-dev \
        libpcre2-dev libcurl4-openssl-dev
RUN rm -rf /var/lib/apt/lists/*

# install svscore dependencies: svtools
RUN wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
RUN python2.7 get-pip.py 
RUN pip2.7 install --use-feature=2020-resolver --disable-pip-version-check --no-cache-dir svtools

# install svscore dependencies: vcfanno
RUN wget https://github.com/brentp/vcfanno/releases/download/v0.3.3/vcfanno_linux64 && \
	chmod a+x vcfanno_linux64 && \
	mv vcfanno_linux64 /usr/local/bin/vcfanno

# install svscore dependencies: perl packages 
RUN wget -O - http://cpanmin.us | perl - --self-upgrade
RUN perl -MCPAN -e '$ENV{FTP_PASSIVE} = 1; install CPAN'
RUN /usr/bin/cpan -fi Test::LeakTrace List::MoreUtils Math::Round 

# install svscore 
RUN mkdir /usr/src/svscore
ENV PATH="/usr/src/svscore:${PATH}"
RUN wget -c https://github.com/lganel/SVScore/archive/refs/tags/v0.6.tar.gz  -O - | tar -xz
RUN mv SVScore-0.6/* /usr/src/svscore/
RUN tree /usr/src/svscore
RUN svscore.pl --version

# run svscore tests
ENV testdir="/usr/src/svscore/tests"
RUN generateannotations.pl -c 1 -a 2 -b 3 -t 4 -s 5 -e 6 -f 7 \
       -o $testdir $testdir/dummyannotations.bed
RUN svscore.pl -f $testdir/dummyannotations.introns.bed \
      -e $testdir/dummyannotations.exons.bed \
      -o max,sum,top2,top2weighted,top3weighted,top4weighted,mean,meanweighted \
      -dvc $testdir/dummyCADD.tsv.gz \
      -i $testdir/stresstest.vcf > $testdir/stresstest.svscore.test.vcf

# print software versions
RUN vcfanno > /software_versions.txt 2>&1 || true
RUN perl --version >> /software_versions.txt
RUN tabix --version >> /software_versions.txt
RUN bgzip --version >> /software_versions.txt
RUN svtools --version >> /software_versions.txt 2>&1
RUN svscore.pl --version >> /software_versions.txt
RUN generateannotations.pl --version >> /software_versions.txt
RUN cat /software_versions.txt

WORKDIR /tmp
CMD ["/bin/bash"]
