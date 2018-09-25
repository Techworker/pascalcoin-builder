#!/usr/bin/env bash

source ./config.sh

error() {
  echo -e "\e[31mPASC: $1\e[0m"
}

info() {
  echo -e "\e[34m$1\e[0m"
}

warning() {
  echo -e "\e[35m$1\e[0m"
}

cleanup() {
  rm -rf $CFG_CHECKOUT_PATH
  rm -rf $CFG_BUILD_PATH
}

execSilent() {
  `$1 &>/dev/null`
}

line() {
    echo "------------------------------------------"
}

loadConfig() {
    line
    info "Loading config file: ${1}"

    # check if we have a config file
    if [ ! -f $1 ]; then
        error "Config not found: ${1}"
        continue
    fi

    source $1
    info "loaded."
}

# cleans up a checked out directory
cleanCheckout() {
    git clean -d -x -f
    git checkout .
    #execSilent "git pull"
    git checkout $1
}

build_wallet_classic() {
    BUILD_BASE_PATH=$1
    BUILD_NAME=$2
    BUILD_OPERATION_SYSTEM=$3
    BUILD_CPU=$4
    BUILD_OPTIMIZATION=$5
    BUILD_MODE=$6
    BUILD_OPENSSL_VERSION=$7

    if [ $BUILD_MODE == "TESTNET" ]; then
        sed -i 's/{\.\$DEFINE TESTNET}/{\$DEFINE TESTNET}/g' config.inc
        sed -i 's/{\$DEFINE PRODUCTION}/{\.\$DEFINE PRODUCTION}/g' config.inc
    fi

    # cleanup
    BUILD_DIR="${BUILD_BASE_PATH}/wallet_classic"
    mkdir -p $BUILD_DIR
    lazbuild --os=$BUILD_OPERATION_SYSTEM --cpu=$BUILD_CPU --build-ide="-O$BUILD_OPTIMIZATION" --no-write-project pascalcoin_wallet_classic.lpi

    if [ $BUILD_OPERATION_SYSTEM == "win32" ] || [ $BUILD_OPERATION_SYSTEM == "win64" ]; then
        cp "PascalCoinWalletLazarus.exe" $BUILD_DIR
    else
        cp "PascalCoinWalletLazarus" $BUILD_DIR
    fi

    cp ../resources/icons/PascalCoinWallet.ico $BUILD_DIR
    cp ../README.md $BUILD_DIR
    cp ../LICENSE.txt $BUILD_DIR

    # this will crash one day!
    if [ $BUILD_OPERATION_SYSTEM == "win32" ]; then
        cp "../../var/openssl/libcrypto-1_1.dll" $BUILD_DIR
    fi

    if [ $BUILD_OPERATION_SYSTEM == "win64" ]; then
        cp "../../var/openssl/libcrypto-1_1-x64.dll" $BUILD_DIR
    fi

    if [ $BUILD_OPERATION_SYSTEM == "linux" ]; then
        cp "../../var/openssl/libcrypto.so.1.1" $BUILD_DIR
    fi

    # hm!
    sleep 5s

    INFO_FILE="${BUILD_DIR}/../../wallet_classic_${BUILD_NAME}.txt"
    TIMESTAMP=$(date +%s)
    echo "TIME=${TIMESTAMP}" >> $INFO_FILE
    echo "BUILD_NAME=${BUILD_NAME}" >> $INFO_FILE
    echo "OS=${BUILD_OPERATION_SYSTEM}" >> $INFO_FILE
    echo "CPU=${BUILD_CPU}" >> $INFO_FILE
    echo "OPTIMIZATION=${BUILD_OPTIMIZATION}" >> $INFO_FILE
    echo "MODE=${BUILD_MODE}" >> $INFO_FILE
    echo "OPENSSL=${BUILD_OPENSSL_VERSION}" >> $INFO_FILE

    if [ $BUILD_OPERATION_SYSTEM == "linux" ]; then
        tar -zcvf "${BUILD_DIR}/../../wallet_classic_${BUILD_NAME}.tar.gz" $BUILD_DIR
    fi

    if [ $BUILD_OPERATION_SYSTEM == "win64" ] || [ $BUILD_OPERATION_SYSTEM == "win32" ]; then
        zip -r "${BUILD_DIR}/../../wallet_classic_${BUILD_NAME}.zip" $BUILD_DIR
    fi

    git clean -d -x -f
    git checkout .
}

build_wallet() {
    BUILD_BASE_PATH=$1
    BUILD_NAME=$2
    BUILD_OPERATION_SYSTEM=$3
    BUILD_CPU=$4
    BUILD_OPTIMIZATION=$5
    BUILD_MODE=$6
    BUILD_OPENSSL_VERSION=$7

    if [ $BUILD_MODE == "TESTNET" ]; then
        sed -i 's/{\.\$DEFINE TESTNET}/{\$DEFINE TESTNET}/g' config.inc
        sed -i 's/{\$DEFINE PRODUCTION}/{\.\$DEFINE PRODUCTION}/g' config.inc
    fi

    # cleanup
    BUILD_DIR="${BUILD_BASE_PATH}/wallet"
    mkdir -p $BUILD_DIR
    lazbuild --os=$BUILD_OPERATION_SYSTEM --cpu=$BUILD_CPU --build-ide="-O$BUILD_OPTIMIZATION" --no-write-project pascalcoin_wallet.lpi

    if [ $BUILD_OPERATION_SYSTEM == "win32" ] || [ $BUILD_OPERATION_SYSTEM == "win64" ]; then
        cp "PascalCoinWallet.exe" $BUILD_DIR
    else
        cp "PascalCoinWallet" $BUILD_DIR
    fi

    cp ../resources/icons/PascalCoinWallet.ico $BUILD_DIR
    cp ../README.md $BUILD_DIR
    cp ../LICENSE.txt $BUILD_DIR

    # this will crash one day!
    if [ $BUILD_OPERATION_SYSTEM == "win32" ]; then
        cp "../../var/openssl/libcrypto-1_1.dll" $BUILD_DIR
    fi

    if [ $BUILD_OPERATION_SYSTEM == "win64" ]; then
        cp "../../var/openssl/libcrypto-1_1-x64.dll" $BUILD_DIR
    fi

    if [ $BUILD_OPERATION_SYSTEM == "linux" ]; then
        cp "../../var/openssl/libcrypto.so.1.1" $BUILD_DIR
    fi

    # hm!
    sleep 5s

    INFO_FILE="${BUILD_DIR}/../../wallet_${BUILD_NAME}.txt"
    TIMESTAMP=$(date +%s)
    echo "TIME=${TIMESTAMP}" >> $INFO_FILE
    echo "BUILD_NAME=${BUILD_NAME}" >> $INFO_FILE
    echo "OS=${BUILD_OPERATION_SYSTEM}" >> $INFO_FILE
    echo "CPU=${BUILD_CPU}" >> $INFO_FILE
    echo "OPTIMIZATION=${BUILD_OPTIMIZATION}" >> $INFO_FILE
    echo "MODE=${BUILD_MODE}" >> $INFO_FILE
    echo "OPENSSL=${BUILD_OPENSSL_VERSION}" >> $INFO_FILE

    if [ $BUILD_OPERATION_SYSTEM == "linux" ]; then
        tar -zcvf "${BUILD_DIR}/../../wallet_${BUILD_NAME}.tar.gz" $BUILD_DIR
    fi

    if [ $BUILD_OPERATION_SYSTEM == "win64" ] || [ $BUILD_OPERATION_SYSTEM == "win32" ]; then
        zip -r "${BUILD_DIR}/../../wallet_${BUILD_NAME}.zip" $BUILD_DIR
    fi

    git clean -d -x -f
    git checkout .
}

build_daemon() {
    BUILD_BASE_PATH=$1
    BUILD_NAME=$2
    BUILD_OPERATION_SYSTEM=$3
    BUILD_CPU=$4
    BUILD_OPTIMIZATION=$5
    BUILD_MODE=$6
    BUILD_OPENSSL_VERSION=$7

    if [ $BUILD_MODE == "TESTNET" ]; then
        sed -i 's/{\.\$DEFINE TESTNET}/{\$DEFINE TESTNET}/g' config.inc
        sed -i 's/{\$DEFINE PRODUCTION}/{\.\$DEFINE PRODUCTION}/g' config.inc
    fi

    # cleanup
    BUILD_DIR="${BUILD_BASE_PATH}/daemon"
    mkdir -p $BUILD_DIR
    lazbuild --os=$BUILD_OPERATION_SYSTEM --cpu=$BUILD_CPU --build-ide="-O$BUILD_OPTIMIZATION" --no-write-project pascalcoin_daemon.lpi

    if [ $BUILD_OPERATION_SYSTEM == "win32" ] || [ $BUILD_OPERATION_SYSTEM == "win64" ]; then
        cp "pascalcoin_daemon.exe" $BUILD_DIR
    else
        cp "pascalcoin_daemon" $BUILD_DIR
    fi

    cp "pascalcoin_daemon.ini" $BUILD_DIR
    cp ../README.md $BUILD_DIR
    cp ../LICENSE.txt $BUILD_DIR

    # this will crash one day!
    if [ $BUILD_OPERATION_SYSTEM == "win32" ]; then
        cp "../../var/openssl/libcrypto-1_1.dll" $BUILD_DIR
    fi

    if [ $BUILD_OPERATION_SYSTEM == "win64" ]; then
        cp "../../var/openssl/libcrypto-1_1-x64.dll" $BUILD_DIR
    fi

    if [ $BUILD_OPERATION_SYSTEM == "linux" ]; then
        cp "../../var/openssl/libcrypto.so.1.1" $BUILD_DIR
    fi

    # hm!
    sleep 5s

    INFO_FILE="${BUILD_DIR}/../../daemon_${BUILD_NAME}.txt"
    TIMESTAMP=$(date +%s)
    echo "TIME=${TIMESTAMP}" >> $INFO_FILE
    echo "BUILD_NAME=${BUILD_NAME}" >> $INFO_FILE
    echo "OS=${BUILD_OPERATION_SYSTEM}" >> $INFO_FILE
    echo "CPU=${BUILD_CPU}" >> $INFO_FILE
    echo "OPTIMIZATION=${BUILD_OPTIMIZATION}" >> $INFO_FILE
    echo "MODE=${BUILD_MODE}" >> $INFO_FILE
    echo "OPENSSL=${BUILD_OPENSSL_VERSION}" >> $INFO_FILE

    if [ $BUILD_OPERATION_SYSTEM == "linux" ]; then
        tar -zcvf "${BUILD_DIR}/../../daemon_${BUILD_NAME}.tar.gz" $BUILD_DIR
    fi

    if [ $BUILD_OPERATION_SYSTEM == "win64" ] || [ $BUILD_OPERATION_SYSTEM == "win32" ]; then
        zip -r "${BUILD_DIR}/../../daemon_${BUILD_NAME}.zip" $BUILD_DIR
    fi

    git clean -d -x -f
    git checkout .
}