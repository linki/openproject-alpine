#!/bin/sh
set -e

cd /app && bin/setup_database && cd -
exec "$@"
