#   Verilator OCI
#   Copyright (c) 2026 Andrea and Eric DELAGE <Contact@by-EAjks.Com>
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.

FROM ubuntu:25.10 AS build

ARG GIT_BRANCH=v5.044

LABEL maintainer="by-EAjks.Com <Contact@by-EAjks.Com>"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update \
 && apt install --yes \
        git \
        autoconf \
        build-essential \
        python3 \
        flex \
        bison \
        help2man

RUN WORKDIR=$(mktemp --directory) \
 && sleep 1 \
 && git clone --branch ${GIT_BRANCH} https://github.com/verilator/verilator ${WORKDIR} \
 && cd ${WORKDIR} \
 && autoconf \
 && ./configure --prefix=/usr/local/verilator \
 && make -j"$(nproc)" \
 && make install

FROM ubuntu:25.10 AS deploy

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update \
 && apt install --yes --no-install-recommends \
        perl \
  && apt autoremove --yes --purge \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/verilator /usr/local/verilator

ENV PATH=/usr/local/verilator/bin${PATH:+:${PATH}}

ENTRYPOINT ["verilator"]
CMD ["--help"]
