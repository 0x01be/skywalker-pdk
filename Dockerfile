FROM 0x01be/alpine:edge as builder

ARG LIBRARY=sky130_fd_sc_hd

RUN apk add --no-cache --virtual skywalker-pdk-build-dependencies \
    git \
    build-base \
    py3-pip \
    py3-setuptools

RUN pip install \
    flake8 \
    rst_include

RUN git clone https://github.com/google/skywater-pdk /opt/skywalker-pdk

WORKDIR /opt/skywalker-pdk

RUN git submodule update --init libraries/$LIBRARY/latest

WORKDIR /opt/skywalker-pdk/scripts/python-skywater-pdk

RUN python3 setup.py install

WORKDIR /opt/skywalker-pdk/libraries

RUN python3 -m skywater_pdk.liberty $LIBRARY/latest
RUN python3 -m skywater_pdk.liberty $LIBRARY/latest all
RUN python3 -m skywater_pdk.liberty $LIBRARY/latest all --ccsnoise

FROM 0x01be/alpine:edge

COPY --from=builder /opt/skywalker-pdk/ /opt/skywalker-pdk/

ENV PDK_ROOT /opt/skywalker-pdk/

