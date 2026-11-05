#!/bin/bash

sesh completion zsh >_sesh

sudo mkdir -p /usr/local/share/zsh/site-functions
sudo mv _sesh /usr/local/share/zsh/site-functions/
