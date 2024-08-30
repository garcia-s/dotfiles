#! /bin/bash
sudo dnf install $(echo $(cat ./install-packages.txt))
current=`$(pwd)`
cd $HOME/.config/
