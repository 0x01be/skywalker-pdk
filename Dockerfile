FROM alpine as build

RUN apk add --no-cache --virtual skywater-pdk-build-dependencies \
    git \
    build-base \
    py3-pip \
    py3-setuptools

RUN pip install \
    flake8 \
    rst_include

ENV REVISION=master
RUN git clone --depth 1 --branch ${REVISION} https://github.com/google/skywater-pdk /opt/skywater-pdk

ARG LIBRARY=sky130_fd_sc_hd
ARG LIBRARY_VERSION=latest
WORKDIR /opt/skywater-pdk
RUN git submodule update --init libraries/${LIBRARY}/${LIBRARY_VERSION}

WORKDIR /opt/skywater-pdk/scripts/python-skywater-pdk

RUN python3 setup.py install

WORKDIR /opt/skywater-pdk/libraries

RUN python3 -m skywater_pdk.liberty ${LIBRARY}/${LIBRARY_VERSION}
RUN python3 -m skywater_pdk.liberty ${LIBRARY}/${LIBRARY_VERSION} all
RUN python3 -m skywater_pdk.liberty ${LIBRARY}/${LIBRARY_VERSION} all --ccsnoise

FROM alpine

COPY --from=build /opt/skywater-pdk/ /opt/skywater-pdk/

ENV PDK_ROOT=/opt/skywater-pdk/

