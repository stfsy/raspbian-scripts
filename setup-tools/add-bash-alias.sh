#!/bin/bash

git clone https://github.com/stfsy/boring-dotfiles
chmod +x boring-dotfiles/deploy.sh
cd boring-dotfiles && chmod +x deploy.sh &&  ./deploy.sh && echo "dotfiles deployed"
cd .. && rm -rf boring-dotfiles