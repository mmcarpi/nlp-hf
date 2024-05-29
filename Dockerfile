FROM nvidia/cuda:12.3.1-base-ubuntu22.04

ARG USER
ARG USERID
ARG GROUPID

ENV PYTHON_VERSION=3.9
#Change for your time zone
ENV TZ=America/Sao_Paulo

ENV WD="/home/$USER"
ENV JUPYTER_PATH="$WD/.local/share/jupyter"
ENV JUPYTER_CONFIG_DIR="$WD/.jupyter"
ENV JUPYTER_RUNTIME_DIR="$WD/.jupyter-runtime/"

RUN addgroup --gid $GROUPID $USER || echo $GROUPID already exists
RUN adduser --disabled-password --gecos '' --uid $USERID --gid $GROUPID $USER

# set time zone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# check python installation
RUN apt-get update && apt-get install -y --no-install-recommends --no-install-suggests\
    tzdata\
    git\
    nano\
    wget
RUN apt-get install -y --reinstall ca-certificates
RUN apt-get clean

# Setup miniforge
# TODO: Use the script already created for this
USER $USER
RUN wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"\
      -O "$WD/Miniforge3-$(uname)-$(uname -m).sh"
USER $USER
RUN bash "$WD/Miniforge3-$(uname)-$(uname -m).sh" -b -u

RUN "$WD/miniforge3/bin/mamba" init bash
COPY ./environment.yaml "$WD"
# install python dependecies
RUN "$WD/miniforge3/bin/mamba" env create -f "$WD/environment.yaml"
RUN echo "mamba activate nlp-hf" >> ~/.bashrc

USER $USER
RUN mkdir -p "$WD/work"
WORKDIR "$WD/work"
CMD bash
