FROM alpine:3.12.0 as builder

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

RUN git clone https://github.com/google/skywater-pdk /skywalker-pdk

WORKDIR /skywalker-pdk

#RUN git checkout 4e5e318e0cc578090e1ae7d6f2cb1ec99f363120
RUN git submodule update --init libraries/sky130_fd_sc_hd/latest

WORKDIR /skywalker-pdk/scripts/python-skywater-pdk

RUN python3 setup.py install

WORKDIR /skywalker-pdk/libraries

RUN python3 -m skywater_pdk.liberty sky130_fd_sc_hd/latest
RUN python3 -m skywater_pdk.liberty sky130_fd_sc_hd/latest all
RUN python3 -m skywater_pdk.liberty sky130_fd_sc_hd/latest all --ccsnoise

