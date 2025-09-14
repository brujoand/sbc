#!/bin/bash

set -e

echo "Testing SBC installation..."

cd /home/testuser/sbc

echo "Running install script..."
./bin/install

echo "Sourcing SBC directly..."
export SBC_PATH="/home/testuser/sbc"
source /home/testuser/sbc/sbc.bash 2>/dev/null

echo "Testing sbl::log::info function..."
if sbl::log::info "Test info message" 2>&1 | grep -q "Test info message"; then
  echo "✓ sbl::log::info works"
else
  echo "✗ sbl::log::info failed"
  exit 1
fi

echo "Testing sbl::log::debug function..."
export SBL_LOG_LEVEL=DEBUG
if sbl::log::debug "Test debug message" 2>&1 | grep -q "Test debug message"; then
  echo "✓ sbl::log::debug works"
else
  echo "✗ sbl::log::debug failed"
  exit 1
fi

echo "Testing sbl::utils::dequote function..."
result=$(sbl::utils::dequote '"quoted string"')
if [ "$result" = "quoted string" ]; then
  echo "✓ sbl::utils::dequote works"
else
  echo "✗ sbl::utils::dequote failed"
  exit 1
fi

echo "Testing sbc command..."
if sbc help >/dev/null 2>&1; then
  echo "✓ sbc command works"
else
  echo "✗ sbc command failed"
  exit 1
fi

echo "All tests passed! SBC installation is working correctly."
