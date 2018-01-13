#!/bin/bash

if [ ! -d "$HOME/.easywork" ]; then
  echo "===================================================================="
  echo "Welcome to use easy work."
  echo "===================================================================="
  git clone https://github.com/xwliuseven/Easy-work.git "$HOME/.easywork"
  cd $HOME/.easywork
  source init.sh
else
  echo "Updating easywork"
  cd $HOME/.easywork
  git checkout .
  git clean -f
  git pull
  source init.sh
fi
  echo "===================================================================="
  echo "Done."
  echo "========================Supported command line======================"
  ruby `pwd`/ez.rb -h
  echo "===================================================================="
  echo "Usage detail please refer to https://github.com/xwliuseven/Easy-work/blob/master/README.md"
  echo "Or you could use ez -h, --help, help"
  echo "Any question/suggestion please contact xwliuseven@gmail.com"
  echo "===================================================================="



