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

ARG LIBRARY_VERSION=latest
WORKDIR /opt/skywater-pdk
RUN git submodule update --init libraries/sky130_fd_io/${LIBRARY_VERSION}
RUN git submodule update --init libraries/sky130_fd_pr/${LIBRARY_VERSION}
RUN git submodule update --init libraries/sky130_fd_sc_hd/${LIBRARY_VERSION}
RUN git submodule update --init libraries/sky130_fd_sc_hdll/${LIBRARY_VERSION}
RUN git submodule update --init libraries/sky130_fd_sc_hs/${LIBRARY_VERSION}
RUN git submodule update --init libraries/sky130_fd_sc_hvl/${LIBRARY_VERSION}
RUN git submodule update --init libraries/sky130_fd_sc_lp/${LIBRARY_VERSION}
RUN git submodule update --init libraries/sky130_fd_sc_ls/${LIBRARY_VERSION}
RUN git submodule update --init libraries/sky130_fd_sc_ms/${LIBRARY_VERSION}

WORKDIR /opt/skywater-pdk/scripts/python-skywater-pdk

RUN python3 setup.py install

WORKDIR /opt/skywater-pdk/libraries

RUN python3 -m skywater_pdk.liberty sky130_sc_hd/${LIBRARY_VERSION}
RUN python3 -m skywater_pdk.liberty sky130_sc_hd/${LIBRARY_VERSION} all
RUN python3 -m skywater_pdk.liberty sky130_sc_hd/${LIBRARY_VERSION} all --ccsnoise
RUN python3 -m skywater_pdk.liberty sky130_sc_hdll/${LIBRARY_VERSION}
RUN python3 -m skywater_pdk.liberty sky130_sc_hdll/${LIBRARY_VERSION} all
RUN python3 -m skywater_pdk.liberty sky130_sc_hdll/${LIBRARY_VERSION} all --ccsnoise
RUN python3 -m skywater_pdk.liberty sky130_sc_hs/${LIBRARY_VERSION}
RUN python3 -m skywater_pdk.liberty sky130_sc_hs/${LIBRARY_VERSION} all
RUN python3 -m skywater_pdk.liberty sky130_sc_hs/${LIBRARY_VERSION} all --ccsnoise
RUN python3 -m skywater_pdk.liberty sky130_sc_hvl/${LIBRARY_VERSION}
RUN python3 -m skywater_pdk.liberty sky130_sc_hvl/${LIBRARY_VERSION} all
RUN python3 -m skywater_pdk.liberty sky130_sc_hvl/${LIBRARY_VERSION} all --ccsnoise
RUN python3 -m skywater_pdk.liberty sky130_sc_lp/${LIBRARY_VERSION}
RUN python3 -m skywater_pdk.liberty sky130_sc_lp/${LIBRARY_VERSION} all
RUN python3 -m skywater_pdk.liberty sky130_sc_lp/${LIBRARY_VERSION} all --ccsnoise
RUN python3 -m skywater_pdk.liberty sky130_sc_ls/${LIBRARY_VERSION}
RUN python3 -m skywater_pdk.liberty sky130_sc_ls/${LIBRARY_VERSION} all
RUN python3 -m skywater_pdk.liberty sky130_sc_ls/${LIBRARY_VERSION} all --ccsnoise
RUN python3 -m skywater_pdk.liberty sky130_sc_ms/${LIBRARY_VERSION}
RUN python3 -m skywater_pdk.liberty sky130_sc_ms/${LIBRARY_VERSION} all
RUN python3 -m skywater_pdk.liberty sky130_sc_ms/${LIBRARY_VERSION} all --ccsnoise
RUN python3 -m skywater_pdk.liberty sky130_sc_ms/${LIBRARY_VERSION} all --leakage

FROM alpine

COPY --from=build /opt/skywater-pdk/ /opt/skywater-pdk/

ENV PDK_ROOT=/opt/skywater-pdk/

