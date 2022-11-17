#!/usr/bin/env bash

cd ../
pip3 install -r requirements.dev.txt
pip3 install -r requirements.txt

pre-commit run --all-files

cd -

rm -rf plots
mkdir -p plots

python3 midterm.py titanic.csv alone 10
