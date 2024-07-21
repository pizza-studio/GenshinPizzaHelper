#!/bin/bash

rm -rf ./Packages/GIPizzaKit/Sources/GIPizzaKit/Enka/Assets/GachaMetaDB.json || true

swift ./Script/GenshinGachaMetaHashDBGenerator.swift > ./Packages/GIPizzaKit/Sources/GIPizzaKit/Enka/Assets/GachaMetaDB.json

echo 'All tasks done.'
