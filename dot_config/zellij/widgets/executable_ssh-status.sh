#!/usr/bin/sh

if [ -z "$SSH_CONNECTION" ]
then
  echo ""
else
  echo "$(hostname)"
fi
