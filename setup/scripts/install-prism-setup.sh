#!/bin/bash

# installing the setup scripts that helps users to configure prism environment

VERSION='1.0.0'

# load config
source ./settings.sh

# copy settings
cp ./settings.sh ${PRISM_BIN_PATH}/bin/setup/

# copy init script
cp ../bin/setup/prism-init.sh ${PRISM_BIN_PATH}/bin/setup/prism-init.sh

# copy remove-settings script
cp ../bin/setup/remove-settings.sh ${PRISM_BIN_PATH}/bin/setup/remove-settings.sh

# copy and configure jumpstart example
tar cvzf ${PRISM_BIN_PATH}/bin/setup/examples.tgz ../data/inputs/*

if [ "$PRISM_SYSTEM_WIDE_INSTALL" == "YES" ]
then
    echo "PATH=\$PATH:${PRISM_BIN_PATH}/bin/setup" | sudo tee /etc/profile.d/prism-setup.sh
fi