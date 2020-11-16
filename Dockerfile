FROM alpine as build

ARG LIBRARY=sky130_fd_sc_hd

RUN apk add --no-cache --virtual skywater-pdk-build-dependencies \
    git \
    build-base \
    py3-pip \
    py3-setuptools

RUN pip install \
    flake8 \
    rst_include

ENV REVISION=master
RUN git clone --depth 1 --branch ${REVISION} https://github.com/google/skywater-pdk /opt/skywalker-pdk

WORKDIR /opt/skywater-pdk

RUN git submodule update --init libraries/$LIBRARY/latest

WORKDIR /opt/skywater-pdk/scripts/python-skywater-pdk

RUN python3 setup.py install

WORKDIR /opt/skywater-pdk/libraries

RUN python3 -m skywater_pdk.liberty $LIBRARY/latest
RUN python3 -m skywater_pdk.liberty $LIBRARY/latest all
RUN python3 -m skywater_pdk.liberty $LIBRARY/latest all --ccsnoise

FROM alpine

COPY --from=build /opt/skywalker-pdk/ /opt/skywalker-pdk/

ENV PDK_ROOT=/opt/skywalker-pdk/

