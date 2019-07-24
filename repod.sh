#!/bin/sh
rm Podfile.lock
pod cache clean --all
pod deintegrate
pod install
