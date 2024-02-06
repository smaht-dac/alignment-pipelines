#######################################################################
#     Basic image
#######################################################################
FROM public.ecr.aws/smaht-dac/base-ubuntu2204-py39:0.0.1

LABEL maintainers="Michele Berselli (berselli.michele@gmail.com), Dominika Maziec (dominika_maziec@hms.harvard.edu)"

#######################################################################
#     General updates & installing necessary Linux components
#       - libncurses-dev, libbz2-dev, liblzma-dev used by samtools
#######################################################################
RUN apt-get update -y && apt-get install -y \
    locales \
    tabix=1.13+ds-2build1 \
    libncurses-dev=6.3-2ubuntu0.1 \
    libbz2-dev=1.0.8-5build1 \
    liblzma-dev=5.2.5-2ubuntu1 \
    --no-install-recommends \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#######################################################################
#     Setting env
#######################################################################
## Set working directory
WORKDIR /usr/local/bin

## Supporting UTF-8
RUN locale-gen "en_US.UTF-8" && update-locale LC_ALL="en_US.UTF-8"
ENV LC_ALL=en_US.UTF-8

#######################################################################
#     Software
#######################################################################
## Install methylink
RUN pip install methylink==0.6.0

## Samtools install
RUN wget https://github.com/samtools/samtools/releases/download/1.17/samtools-1.17.tar.bz2 && \
    tar -xjf samtools-1.17.tar.bz2 && \
    rm -rf samtools-1.17.tar.bz2

WORKDIR /usr/local/bin/samtools-1.17
RUN ./configure && \
    make

WORKDIR /usr/local/bin/
RUN ln -s samtools-1.17 samtools

#######################################################################
#     Scripts
#######################################################################
## ImportReadGroups_methylink
COPY ImportReadGroups_methylink.sh .
RUN chmod +x ImportReadGroups_methylink.sh

#######################################################################
#     Update env
#######################################################################
ENV PATH=/usr/local/bin/samtools/:$PATH

CMD ["bash"]
