#!/bin/sh

cd ../
pip3 install -r requirements.dev.txt
pip3 install -r requirements.txt

pre-commit run --all-files

cd -

rm -rf graphs 

python3 feature_engg.py

