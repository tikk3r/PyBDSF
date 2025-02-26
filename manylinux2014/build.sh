#!/bin/bash
#
# Script to make python wheels for several versions

set -eu

SCRIPT_DIR=$(cd $(dirname $0) && pwd)
ROOT_DIR=$(git rev-parse --show-toplevel)

py_major=3
for py_minor in $(seq 6 10); do
    echo -e "\n\n******** Building wheel for python ${py_major}.${py_minor} ********\n"
    py_version=${py_major}${py_minor}
    [ ${py_minor} -le 7 ] && py_unicode="m" || py_unicode=
    docker build \
        --build-arg PYMAJOR=${py_major} \
        --build-arg PYMINOR=${py_minor} \
        --build-arg PYUNICODE=${py_unicode} \
        --file ${SCRIPT_DIR}/py_wheel.docker \
        --tag bdsf-py${py_version} \
        ${ROOT_DIR}
    dockerid=$(docker create bdsf-py${py_version})
    docker cp ${dockerid}:/dist ${ROOT_DIR}
    docker rm ${dockerid}
done
