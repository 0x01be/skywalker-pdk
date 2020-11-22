FROM alpine as build

RUN apk add --no-cache --virtual skywater-pdk-build-dependencies \
    git \
    build-base \
    py3-pip \
    py3-setuptools &&\
    pip install \
    flake8 \
    rst_include

ENV REVISION=master
RUN git clone --depth 1 --branch ${REVISION} https://github.com/google/skywater-pdk /opt/skywater-pdk

WORKDIR /opt/skywater-pdk

ARG LIBRARY_VERSION=latest
RUN git submodule update --init libraries/sky130_fd_io/${LIBRARY_VERSION} &&\
    git submodule update --init libraries/sky130_fd_pr/${LIBRARY_VERSION} &&\ 
    git submodule update --init libraries/sky130_fd_sc_hd/${LIBRARY_VERSION} &&\ 
    git submodule update --init libraries/sky130_fd_sc_hdll/${LIBRARY_VERSION} &&\ 
    git submodule update --init libraries/sky130_fd_sc_hs/${LIBRARY_VERSION} &&\ 
    git submodule update --init libraries/sky130_fd_sc_hvl/${LIBRARY_VERSION} &&\ 
    git submodule update --init libraries/sky130_fd_sc_lp/${LIBRARY_VERSION} &&\ 
    git submodule update --init libraries/sky130_fd_sc_ls/${LIBRARY_VERSION} &&\ 
    git submodule update --init libraries/sky130_fd_sc_ms/${LIBRARY_VERSION}

WORKDIR /opt/skywater-pdk/scripts/python-skywater-pdk

RUN python3 setup.py install

WORKDIR /opt/skywater-pdk/libraries

RUN python3 -m skywater_pdk.liberty sky130_fd_sc_hd/${LIBRARY_VERSION} &&\ 
    python3 -m skywater_pdk.liberty sky130_fd_sc_hd/${LIBRARY_VERSION} all &&\ 
    python3 -m skywater_pdk.liberty sky130_fd_sc_hd/${LIBRARY_VERSION} all --ccsnoise &&\ 
    python3 -m skywater_pdk.liberty sky130_fd_sc_hdll/${LIBRARY_VERSION} &&\ 
    python3 -m skywater_pdk.liberty sky130_fd_sc_hdll/${LIBRARY_VERSION} all &&\ 
    python3 -m skywater_pdk.liberty sky130_fd_sc_hdll/${LIBRARY_VERSION} all --ccsnoise &&\ 
    python3 -m skywater_pdk.liberty sky130_fd_sc_hs/${LIBRARY_VERSION} &&\ 
    python3 -m skywater_pdk.liberty sky130_fd_sc_hs/${LIBRARY_VERSION} all &&\ 
    python3 -m skywater_pdk.liberty sky130_fd_sc_hs/${LIBRARY_VERSION} all --ccsnoise &&\ 
    python3 -m skywater_pdk.liberty sky130_fd_sc_hvl/${LIBRARY_VERSION} &&\ 
    python3 -m skywater_pdk.liberty sky130_fd_sc_hvl/${LIBRARY_VERSION} all &&\ 
    python3 -m skywater_pdk.liberty sky130_fd_sc_hvl/${LIBRARY_VERSION} all --ccsnoise &&\ 
    python3 -m skywater_pdk.liberty sky130_fd_sc_lp/${LIBRARY_VERSION} &&\ 
    python3 -m skywater_pdk.liberty sky130_fd_sc_lp/${LIBRARY_VERSION} all &&\ 
    python3 -m skywater_pdk.liberty sky130_fd_sc_lp/${LIBRARY_VERSION} all --ccsnoise &&\ 
    python3 -m skywater_pdk.liberty sky130_fd_sc_ls/${LIBRARY_VERSION} &&\ 
    python3 -m skywater_pdk.liberty sky130_fd_sc_ls/${LIBRARY_VERSION} all &&\ 
    python3 -m skywater_pdk.liberty sky130_fd_sc_ls/${LIBRARY_VERSION} all --ccsnoise &&\ 
    python3 -m skywater_pdk.liberty sky130_fd_sc_ms/${LIBRARY_VERSION} &&\ 
    python3 -m skywater_pdk.liberty sky130_fd_sc_ms/${LIBRARY_VERSION} all &&\ 
    python3 -m skywater_pdk.liberty sky130_fd_sc_ms/${LIBRARY_VERSION} all --ccsnoise &&\ 
    python3 -m skywater_pdk.liberty sky130_fd_sc_ms/${LIBRARY_VERSION} all --leakage

FROM alpine

COPY --from=build /opt/skywater-pdk/ /opt/skywater-pdk/

ENV PDK_ROOT=/opt/skywater-pdk/

