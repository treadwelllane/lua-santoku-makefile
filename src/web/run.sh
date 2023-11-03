#!/bin/bash
set -ex
set -o pipefail
cd "$(dirname $0)"
openresty -c "nginx.conf" -p "$PWD" -e error.log
