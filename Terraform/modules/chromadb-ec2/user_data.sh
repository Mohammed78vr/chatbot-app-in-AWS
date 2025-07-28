#!/bin/bash

sudo apt update
sudo apt install -y gnupg2 wget git

sudo -u ubuntu systemctl restart chromadb