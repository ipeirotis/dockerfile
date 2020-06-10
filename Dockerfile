FROM ubuntu:latest

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV PYTHONIOENCODING UTF-8

ARG DEBIAN_FRONTEND=noninteractive

ENV NB_USER ubuntu
ENV SHELL /bin/bash
RUN useradd -ms /bin/bash ubuntu

RUN chmod -R 777 /home

RUN apt-get -qy update && \
        apt-get -qy dist-upgrade && \
        apt-get -qy upgrade
        
RUN apt-get -qy install \
        sudo \
        nano \
        cron \
        curl \
        git \
        wget \
        jq

RUN apt-get -qy install \
        build-essential \
        python3-dev \
        python3-pip 
        
RUN apt-get clean && \
        rm -rf /var/lib/apt/lists/*

# install latest version of pip
RUN pip3 install -U pip

# Code formatter and linter
RUN pip3 install black flake8

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
    
# install basic Python libraries to run Jupyter
RUN pip3 install jupyter 

  
# Enable extensions
RUN pip3 install jupyter_contrib_nbextensions
RUN jupyter contrib nbextension install --system

RUN jupyter nbextension enable --system collapsible_headings/main
RUN jupyter nbextension enable --system exercise2/main
RUN jupyter nbextension enable --system spellchecker/main

# Install Black as an extension
RUN jupyter nbextension install https://github.com/drillan/jupyter-black/archive/master.zip --user
RUN jupyter nbextension enable jupyter-black-master/jupyter-black

RUN mkdir -p /etc/jupyter
RUN echo "c.NotebookApp.password = 'sha1:44967f2c7dbb:4ae5e013fa8bae6fd8d4b8fa88775c0c5caeffbf'" >> /etc/jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.allow_root = True" >> /etc/jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.notebook_dir = '/home/ubuntu/notebooks'" >> /etc/jupyter/jupyter_notebook_config.py

RUN echo "ALL  ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers

EXPOSE 8888

USER $NB_USER
RUN mkdir -p /home/ubuntu/notebooks
WORKDIR /home/ubuntu/notebooks

CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]
