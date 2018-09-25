#!/usr/bin/env bash

# load helper and config
source helpers.sh

info "PascalCoin build started"

# load the basic config
loadConfig "${PWD}/config.sh"

# first run: if the repo is not checked out yet, we will do so
if [ ! -d $CFG_MAIN_CHECKOUT_PATH ]; then
  git clone $CFG_MAIN_REPOSITORY $CFG_MAIN_CHECKOUT_PATH
fi

# first run: create the builds directory
if [ ! -d $CFG_MAIN_BUILD_PATH ]; then
  mkdir $CFG_MAIN_BUILD_PATH
fi

# we are in the project now to refresh the checkout
cd $CFG_MAIN_CHECKOUT_PATH

info "Fetching remote changes"

# now we will clean the checked out project completely (latest run) and
# checkout the master - its as if we have a fresh clone
git clean -d -x -f
git checkout .
#git pull --all
git checkout master

# back home
cd $CFG_MAIN_HOME

# now we will read all active branch configurations
for CFG_BRANCH_CONFIG_FILE in "${CFG_BRANCH_CONFIG_FILES[@]}"
do
    # load branch config
    loadConfig $CFG_BRANCH_CONFIG_FILE
    info "Branch: ${CFG_BRANCH_NAME}"

    # go to repository and check if the branch exists
    cd $CFG_MAIN_CHECKOUT_PATH

    # check if the branch exists
    git rev-parse --verify $CFG_BRANCH_NAME

    if [[ $? -ne "0" ]]
    then
        error "BRANCH $CFG_BRANCH_NAME does not exist in the repository!"
        continue
    fi

    # create the build path for the branch
    BRANCH_BUILD_PATH="${CFG_MAIN_BUILD_PATH}/${CFG_BRANCH_NAME}"
    if [ ! -d $BRANCH_BUILD_PATH ]; then
        mkdir -p $BRANCH_BUILD_PATH
    fi

    # fetch the latest commit, this is what we want to build
    LATEST_COMMIT=`git rev-parse --short=40 HEAD`

    info "Latest commit: ${LATEST_COMMIT} in branch ${CFG_BRANCH_NAME}."

    # check if we already built that one, if so we can skip it
    COMMIT_BUILD_PATH="${BRANCH_BUILD_PATH}/${LATEST_COMMIT}"
    if [ -d "$COMMIT_BUILD_PATH" ]; then
        warning "Build for commit $LATEST_COMMIT already exists!"
        continue
    fi

    # create the commit build path
    mkdir -p $COMMIT_BUILD_PATH

    # now loop the build configs and build the projects
    info "Building commit $LATEST_COMMIT ON BRANCH $CFG_BRANCH_NAME"

    # loop all branch build configs
    for CURRENT_BUILD_CONFIG_FILE in "${CFG_BRANCH_BUILD_CONFIG_FILES[@]}"
    do
        # read build config
        loadConfig $CURRENT_BUILD_CONFIG_FILE

        info "Name: $BUILD_NAME"
        info "OS: $BUILD_OPERATION_SYSTEM"
        info "CPU: $BUILD_CPU"
        info "OPTIMIZATION: $BUILD_OPTIMIZATION"
        info "MODE: $BUILD_MODE"
        info "OPENSSL: $BUILD_OPENSSL_VERSION"

        mkdir -p "${COMMIT_BUILD_PATH}/${BUILD_NAME}"

        # clean the checkout, we will not pull!
        cd $CFG_MAIN_CHECKOUT_PATH

        git clean -d -x -f
        git checkout .
        git checkout $CFG_BRANCH_NAME

        # goto src folder
        cd "${CFG_MAIN_CHECKOUT_PATH}/src"

        COMMIT_PROJECT_BUILD_PATH="${COMMIT_BUILD_PATH}/${BUILD_NAME}"

        # loop the projects to build
        for PROJECT in "${BUILD_PROJECTS[@]}"
        do
            case $PROJECT in
                "wallet_classic")
                    build_wallet_classic "${COMMIT_PROJECT_BUILD_PATH}" "${BUILD_NAME}" "${BUILD_OPERATION_SYSTEM}" "${BUILD_CPU}" "${BUILD_OPTIMIZATION}" "${BUILD_MODE}" "${BUILD_OPENSSL_VERSION}"
                    ;;
                "daemon")
                    build_daemon "${COMMIT_PROJECT_BUILD_PATH}" "${BUILD_NAME}" "${BUILD_OPERATION_SYSTEM}" "${BUILD_CPU}" "${BUILD_OPTIMIZATION}" "${BUILD_MODE}" "${BUILD_OPENSSL_VERSION}"
                    ;;
                "wallet")
                    build_wallet "${COMMIT_PROJECT_BUILD_PATH}" "${BUILD_NAME}" "${BUILD_OPERATION_SYSTEM}" "${BUILD_CPU}" "${BUILD_OPTIMIZATION}" "${BUILD_MODE}" "${BUILD_OPENSSL_VERSION}"
                    ;;
            esac
        done

        rm -rf $COMMIT_PROJECT_BUILD_PATH

    done

#    for BUILD_CONFIG_FILE in "${CONFIGS[@]}"
#    do#
#
#        BUILD_CONFIG_FILE="config/${BUILD_CONFIG_FILE}"
#        # check if we have a config file
#        if [ ! -f $BUILD_CONFIG_FILE ]; then
#            error "build config not found: $BUILD_CONFIG_FILE"
#            continue
#        fi
#
#        into "Buildung from config ${BUILD_CONFIG_FILE}"
#        source $BUILD_CONFIG_FILE
#
#        cd src
#
#    done

done



#    for MODE in "${MODES[@]}"
#    do
#        git clean -d -x -f
#        git checkout .
#        git checkout $BRANCH##
#
#        if [ $MODE == "TESTNET" ];
#        then
#            sed -i 's/{\.\$DEFINE TESTNET}/{\$DEFINE TESTNET}/g' config.inc
#            sed -i 's/{\$DEFINE PRODUCTION}/{\.\$DEFINE PRODUCTION}/g' config.inc
#        fi
#        for OPT in "${OPTIMIZATIONS[@]}"
#        do
#            for OS in "${OPERATION_SYSTEMS[@]}"
#                do
#                    build_wallet_classic "$OS" "$OPT" $MODE
#                    build_wallet "$OS" "$OPT" $MODE
#                    build_daemon "$OS" "$OPT" $MODE
#                done
#            done
#        done
#    done

#cd /home/pascal/pascal_src
#git clean -d -x -f
#git checkout .
#git pull
#cd src
#sed -i 's/{\.\$DEFINE TESTNET}/{\$DEFINE TESTNET}/g' config.inc
#sed -i 's/{\$DEFINE PRODUCTION}/{\.\$DEFINE PRODUCTION}/g' config.inc
#fpc -Fucore -Fulibraries/synapse -Fulibraries/pascalcoin -Fulibraries/sphere10 -Fulibraries/generics.collections -Fu"/usr/lib/lazarus/1.8.2/components/lazutils" -Fulibraries/hashlib4pascal -Tlinux -O- -opascalcoin_daemon pascalcoin_daemon.pp
#cp pascalcoin_daemon ../../pascal_bin/pascalcoin_daemon
#cp pascalcoin_daemon.ini ../../pascal_bin/pascalcoin_daemon.ini