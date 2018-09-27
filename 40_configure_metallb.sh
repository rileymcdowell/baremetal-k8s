#!/bin/bash

# From https://metallb.universe.tf/

pushd metallb

./00_*.sh
./05_*.sh
./10_*.sh

popd

