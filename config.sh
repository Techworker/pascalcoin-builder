#!/usr/bin/env bash

# the remote repository
CFG_MAIN_REPOSITORY="https://github.com/PascalCoin/PascalCoin.git"

# the path to the checkout repository
CFG_MAIN_CHECKOUT_PATH="${PWD}/checkout"

# the path to the builds
CFG_MAIN_RELEASES_PATH="${PWD}/builds"

# the path to all configs
CFG_MAIN_CONFIG_PATH="${PWD}/config"

# the list of active configuration files
CFG_MAIN_BRANCH_FILES=( "${CFG_MAIN_CONFIG_PATH}/branches/master.sh" )

# the folder where the files will be copied to in the build process to pack them
CFG_MAIN_TMP_BUILD_DIR="${PWD}/tmp"

# home directory
CFG_MAIN_HOME=$PWD