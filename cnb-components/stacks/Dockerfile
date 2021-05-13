## ---Base image---

FROM ubuntu:bionic as base

# Set required CNB information
ENV CNB_USER_ID=1000
ENV CNB_GROUP_ID=1000
ENV CNB_STACK_ID="com.altoros.demo.cnb.stacks.ubuntu"
LABEL io.buildpacks.stack.id="com.altoros.demo.cnb.stacks.ubuntu"

# Create user and group
RUN groupadd cnb --gid ${CNB_GROUP_ID} && \
  useradd --uid ${CNB_USER_ID} --gid ${CNB_GROUP_ID} -m -s /bin/bash cnb

# Install packages that we want to make available at both build and run time
RUN apt-get update && \
  apt-get install -y xz-utils ca-certificates apt-transport-https gnupg && \
  rm -rf /var/lib/apt/lists/*

## ---Build image---

FROM base as build

# Install packages that we want to make available at build time
RUN apt-get update && \
  apt-get install -y git wget jq && \
  rm -rf /var/lib/apt/lists/* && \
  wget https://github.com/sclevine/yj/releases/download/v5.0.0/yj-linux -O /usr/local/bin/yj && \
  chmod +x /usr/local/bin/yj

# Declare dependencies this image provides
LABEL io.buildpacks.stack.mixins="[\"build:wget\", \"build:jq\", \"build:yj\"]"

# Set user and group (as declared in base image)
USER ${CNB_USER_ID}:${CNB_GROUP_ID}

## ---Run image---

FROM base as run

# Set user and group (as declared in base image)
USER ${CNB_USER_ID}:${CNB_GROUP_ID}
