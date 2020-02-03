#!/bin/bash

if f5fpc --info | grep 'session established' > /dev/null; then
  echo "VPN"
fi
