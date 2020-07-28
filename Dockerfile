FROM alpine:3.12.0 as builder

ARG LIBRARY=sky130_fd_sc_hd

RUN apk add --no-cache --virtual build-dependencies \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
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

FROM alpine:3.12.0

COPY --from=builder /opt/skywalker-pdk/ /opt/skywalker-pdk/

