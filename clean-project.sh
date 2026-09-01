#!/bin/bash

flutter clean;
flutter pub get;

cd android;
./gradlew clean;
cd ..;