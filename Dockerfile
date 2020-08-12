FROM alpine as builder

ARG LIBRARY=sky130_fd_sc_hd

RUN apk add --no-cache --virtual skywater-pdk-build-dependencies \
    git \
    build-base \
    py3-pip \
    py3-setuptools

RUN pip install \
    flake8 \
    rst_include

RUN git clone https://github.com/google/skywater-pdk /opt/skywater-pdk

WORKDIR /opt/skywater-pdk

RUN git submodule update --init libraries/$LIBRARY/latest

WORKDIR /opt/skywater-pdk/scripts/python-skywater-pdk

RUN python3 setup.py install

WORKDIR /opt/skywater-pdk/libraries

RUN python3 -m skywater_pdk.liberty $LIBRARY/latest
RUN python3 -m skywater_pdk.liberty $LIBRARY/latest all
RUN python3 -m skywater_pdk.liberty $LIBRARY/latest all --ccsnoise

FROM alpine

COPY --from=builder /opt/skywater-pdk/ /opt/skywater-pdk/

ENV PDK_ROOT /opt/skywater-pdk/

