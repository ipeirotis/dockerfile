FROM ubuntu:latest
  
# Configure environment
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV PYTHONIOENCODING UTF-8
ENV SHELL=/bin/bash
ENV NB_USER="ubuntu"
ENV NB_UID="1000"
ENV NB_GID="100"    

ARG NETRC
ENV DEBIAN_FRONTEND noninteractive

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# We still setup everything as root, change permissions later
USER root



RUN apt-get -qy update && \
    apt-get upgrade --yes && \
    apt-get install -yq --no-install-recommends \
      wget \
      bzip2 \
      ca-certificates \
      sudo \
      locales \
      fonts-liberation \
      pandoc \
      tini \
      run-one

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

RUN dpkg-reconfigure locales
    

RUN  apt-get install -yq  --no-install-recommends \
      nano \
      cron \
      curl \
      git \
      tzdata \
      less \
      OpenSSH-client \      
      vim \
      jq && \
  apt-get install -qy  --no-install-recommends \
      texlive-xetex \
      texlive-fonts-recommended \
      texlive-plain-generic && \  
  apt-get install -qy  --no-install-recommends \
      build-essential \
      cm-super \
      dvipng \
      ffmpeg \
      python3-dev \
      python3-pip 

    
RUN apt-get clean && \
        rm -rf /var/lib/apt/lists/*

# Copy a script that we will use to correct permissions after running certain commands
COPY fix-permissions /usr/local/bin/fix-permissions
RUN chmod a+rx /usr/local/bin/fix-permissions
COPY start-notebook.sh /usr/local/bin/
RUN chmod a+rx /usr/local/bin/start-notebook.sh

# Enable prompt color in the skeleton .bashrc before creating the default NB_USER
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc

# Create NB_USER with name jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
    sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers && \
    sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers && \
    useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    chmod g+w /etc/passwd && \
    fix-permissions /home/$NB_USER

RUN echo "ALL  ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers

# Setup work directory
RUN mkdir -p /home/$NB_USER/notebooks
RUN chown -R $NB_USER:$NB_GID /home/$NB_USER
RUN fix-permissions /home/$NB_USER



# install latest version of pip
RUN pip3 install -U pip

# Code formatter and linter
RUN pip3 install \
        Black \
        sort \
        yapf \
        autopep8 \
        flake8 \
        flake8-nb

# Code for interacting with MySQL
RUN pip3 install \
        PyMySQL \
        sqlalchemy

# Add standard data science libraries
RUN pip3 install \
    numpy \
    scipy \
    cython \
    pandas \
    dask \
    sympy \
    h5py \
    xlrd \
    openpyxl \
    numba \
    statsmodels
    

RUN pip3 install \
    scikit-learn \
    tensorflow \
    keras \
    torch \
    torchvision \
    torchaudio 

# Add standard visualization libraries
RUN pip3 install \
    altair \
    bokeh \
    matplotlib \
    pandas \
    seaborn \
    pytables
    
# add geospatial libraries
RUN pip3 install \
    shapely \
    pyproj \
    fiona \
    geopandas \
    program \
    Descartes \
    folium \ 
    geoplot \
    mapclassify


# add libraries for teaching web APIs
RUN pip3 install \
    requests \
    Flask
    
# add libraries for NLP
RUN pip3 install \
    spacy \
    nltk
    
# Add libraries for Web crawling
RUN pip3 install \
    bs4   
    
# install basic Python libraries to run Jupyter
RUN pip3 install \
    jupyter \
    notebook \
    nbformat \
    nbstripout \
    jupyterlab-code-formatter \
    jupyterlab-git \
    ipywidgets \ 
    widgetsnbextension \ 
    jupyterlab


COPY overrides.json /opt/conda/share/jupyter/lab/settings/

COPY jupyter_notebook_config.py /etc/jupyter/
RUN echo "c.NotebookApp.password = 'sha1:44967f2c7dbb:4ae5e013fa8bae6fd8d4b8fa88775c0c5caeffbf'" >> /etc/jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.notebook_dir = '/home/ubuntu/notebooks'" >> /etc/jupyter/jupyter_notebook_config.py

# Import matplotlib the first time to build the font cache
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions "/home/${NB_USER}"


USER $NB_UID
ENV HOME=/home/$NB_USER
ENV PATH=$HOME/.local/bin:$PATH
WORKDIR $HOME

RUN echo "$NETRC" > $HOME/.netrc
RUN chmod 600 $HOME/.netrc

# Open port for Jupyter
EXPOSE 8888

ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["start-notebook.sh"]

