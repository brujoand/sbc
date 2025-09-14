#!/usr/bin/env bash

cd "$(dirname "$0")/.." || exit

echo "Building Docker test image..."
docker build -f scripts/Dockerfile.test -t sbc-test .

echo "Running installation test..."
docker run --rm sbc-test /home/testuser/sbc/scripts/test_install.sh
