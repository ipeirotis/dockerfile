FROM ubuntu:latest

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV PYTHONIOENCODING UTF-8

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -qy update && \
        apt-get -qy dist-upgrade && \
        apt-get -qy upgrade
        
RUN apt-get -qy install \
        sudo \
        nano \
        cron \
        build-essential \
        python3-dev \
        curl \
        git \
        wget \
        jq

RUN apt-get clean && \
        rm -rf /var/lib/apt/lists/*

# install latest version of pip
RUN pip3 install -U pip

# add standard data science libraries
RUN pip3 install \
    numpy \
    scipy \
    matplotlib \
    pandas \
    seaborn \
    statsmodels \
    scikit-learn

# add libraries for teaching web APIs
RUN pip3 install \
    requests \
    Flask
    
# add libraries for NLP
RUN pip3 install \
    spacy \
    nltk

RUN chmod -R 777 /home
