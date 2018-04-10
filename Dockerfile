FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04


LABEL maintainer="syschat <syschat@naver.com>"


ARG PY_VER=3.6
ENV DOCKER_VERSION=0.060

USER root


RUN apt-get update && apt-get -yq dist-upgrade && \
  apt-get install -yq --no-install-recommends \
    wget  apt-utils   git vim apt-transport-https \
    bzip2 ssh  graphviz \
    ca-certificates \
    sudo \
    locales \
    fonts-liberation \
    fonts-nanum-coding && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

#로케일설정  
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen




# 환경 변수 
ENV VENV_DIR=/opt/venv \
    SHELL=/bin/bash \
    NB_USER=syschat \
    NB_UID=1000 \
    NB_GID=100 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
ENV PATH=$VENV_DIR/bin:$PATH \
    HOME=/home/$NB_USER \
    LD_LIBRARY_PATH="/usr/local/lib/:${LD_LIBRARY_PATH}"


ADD fix-permissions /usr/local/bin/fix-permissions
# Create syschat user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
#사용자 권한 및 계정 설정 
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    mkdir -p $VENV_DIR && \
    chown $NB_USER:$NB_GID $VENV_DIR && \
    fix-permissions $HOME && \
    fix-permissions $VENV_DIR


USER $NB_USER

# Setup work directory for backward-compatibility
#virtualenv로 개인 권한 내에서  파이썬 설치 
RUN mkdir /home/$NB_USER/work && \
    fix-permissions /home/$NB_USER && \
    python$PY_VER -m venv $VENV_DIR && \
    /bin/bash -c "source $VENV_DIR/bin/activate"

#추후 python의 경우 GPU버전과 CPU버전의 이미지 분리가 필요함 
RUN pip$PY_VER install --upgrade pip && \
    pip$PY_VER install --no-cache-dir python-crfsuite pydot python-telegram-bot  tqdm jpype1 konlpy pandas scipy numpy \
      jupyter jupyterhub jupyter_contrib_nbextensions ipywidgets \
      jupyter_nbextensions_configurator jupyterlab jupyterthemes \
      sklearn matplotlib seaborn rpy2 gensim  opencv-python scikit-image  && \ 
    jupyter serverextension enable --py jupyterlab --sys-prefix && \
    pip$PY_VER install --no-cache-dir mxnet-cu90 tensorflow-gpu keras && \
    jupyter nbextension enable --py widgetsnbextension --sys-prefix --user  && \
    jupyter nbextensions_configurator enable --user && \
    jupyter nbextension install https://github.com/ipython-contrib/IPython-notebook-extensions/archive/master.zip --user && \
    jupyter nbextension install https://github.com/Calysto/notebook-extensions/archive/master.zip --user


#install konlpy mecab
RUN curl -fSsL -O https://raw.githubusercontent.com/konlpy/konlpy/master/scripts/mecab.sh && \
    chmod +x mecab.sh && \
    ./mecab.sh


RUN mkdir -p $HOME/py_libs/lib/python$PY_VER/site-packages && \
    fix-permissions $HOME/py_libs/ && \
    echo 'PYTHONUSERBASE='$HOME'/py_libs/\n'\
         'PYTHONPATH='$HOME'/py_libs/lib/python'$PY_VER'/site-packages\n'\
         'JUPYTER_PATH='$HOME'/py_libs/lib/python'$PY_VER'/site-packages\n'\
          >>  /etc/environment



EXPOSE 8888-9000
WORKDIR $HOME

# Configure container startup
ENTRYPOINT ["tini", "--"]
CMD ["start-notebook.sh"]

# Add local files as late as possible to avoid cache busting
COPY start-notebook.sh  /usr/local/bin/
COPY start.sh  /usr/local/bin/
COPY start-singleuser.sh  /usr/local/bin/
COPY jupyter_notebook_config.py  /etc/jupyter/
RUN fix-permissions  /etc/jupyter/ && \
    fix-permissions $HOME/.jupyter/ 

#time zone 
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#mxnet 환경 변수 
#ENV MXNET_CUDNN_AUTOTUNE_DEFAULT=1 \
#    MXNET_ENGINE_TYPE=ThreadedEngine

#ENV CUDA_DEVICE_ORDER=PCI_BUS_ID \
#    CUDA_VISIBLE_DEVICES='1,0'


# Switch back to syschat to avoid accidental container runs as root
USER $NB_USER

ENV PYTHONUSERBASE=$HOME/py_libs/
ENV PYTHONPATH=$PYTHONUSERBASE/lib/python$PY_VER/site-packages:$PYTHONPATH

