#!/bin/bash

rm -rf /var/tmp/temporaryJSON4Enka/ || true
mkdir /var/tmp/temporaryJSON4Enka/
git clone https://github.com/pizza-studio/EnkaDBGenerator.git /var/tmp/temporaryJSON4Enka/

cp /var/tmp/temporaryJSON4Enka/Sources/EnkaDBFiles/Resources/Specimen/GI/*.json ./Packages/GIPizzaKit/Sources/GIPizzaKit/Enka/Assets/

rm -rf /var/tmp/temporaryJSON4Enka/

cd ./Packages/GIPizzaKit/Sources/GIPizzaKit/Enka/Assets/
ls

echo 'All tasks done.'
