FROM 0x01be/base as build

ENV PDK_ROOT=/opt/skywater-pdk
ARG REVISION=master
ARG LIBRARY_VERSION=latest
RUN apk add --no-cache --virtual skywater-pdk-build-dependencies \
    git \
    build-base \
    py3-pip \
    py3-setuptools &&\
    pip install \
    flake8 \
    rst_include &&\
    git clone --depth 1 --branch ${REVISION} https://github.com/google/skywater-pdk ${PDK_ROOT}

WORKDIR ${PDK_ROOT}
RUN git submodule update --init libraries/sky130_fd_io/${LIBRARY_VERSION} &&\
    git submodule update --init libraries/sky130_fd_sc_hd/${LIBRARY_VERSION} &&\ 
    git submodule update --init libraries/sky130_fd_sc_hvl/${LIBRARY_VERSION} &&\ 

WORKDIR ${PDK_ROOT}/scripts/python-skywater-pdk
RUN python3 setup.py install

WORKDIR ${PDK_ROOT}/libraries
RUN python3 -m skywater_pdk.liberty sky130_fd_sc_hd/${LIBRARY_VERSION} &&\ 
    python3 -m skywater_pdk.liberty sky130_fd_sc_hd/${LIBRARY_VERSION} all &&\ 
    python3 -m skywater_pdk.liberty sky130_fd_sc_hd/${LIBRARY_VERSION} all --ccsnoise &&\ 
    python3 -m skywater_pdk.liberty sky130_fd_sc_hvl/${LIBRARY_VERSION} all &&\ 
    python3 -m skywater_pdk.liberty sky130_fd_sc_hvl/${LIBRARY_VERSION} all --ccsnoise

