#!/usr/bin/env bash
set -eo pipefail

# Create the stack images
pushd stacks
    docker build . -t altoros/build-image:ubuntu --target build
    docker build . -t altoros/run-image:ubuntu --target run
popd

pushd buildpacks/gradle
    pack buildpack package altoros/buildpack:gradle --config ./package.toml
popd

pushd builders
    pack builder create altoros/builder:ubuntu --config ./builder.toml
popd