#!/bin/bash
#
# Copyright 2019-2023 SUSE LLC
# SPDX-License-Identifier: GPL-2.0-or-later

set -e

thisdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cre="${cre:-"podman"}"
$cre build -t localtest -f- "$thisdir"<<EOF
FROM registry.opensuse.org/devel/openqa/ci/containers/base:latest

RUN sudo zypper ar -f -p 90 https://download.opensuse.org/repositories/devel:/openQA:/Leap:/15.5/15.5 openQA
RUN sudo zypper ar -f -p 95 http://download.opensuse.org/repositories/devel:openQA/15.5 devel
RUN sudo zypper --gpg-auto-import-keys ref

RUN sudo zypper -n install $(sed -e 's/\r//' < "$thisdir/ci-packages.txt" | sort | tr -s '\n' ' ')

COPY build_autoinst.sh .
RUN sudo mkdir '../os-autoinst'
RUN sudo chown 1000 '../os-autoinst'
RUN pwd && ls -la
RUN ./build_autoinst.sh '../os-autoinst' $(cat "$thisdir/autoinst.sha")
RUN sudo chown -R 1000 '/opt/testing_area'
WORKDIR /opt/testing_area
USER squamata
EOF
