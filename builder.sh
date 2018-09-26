#!/usr/bin/env bash
#
# Performs builds on a PascalCoin source base.

# displays an error message (red)
pasc::error() {
  echo -e "\e[31mPASC: $1\e[0m"
}

# Display an info message (blueish)
pasc::info() {
  echo -e "\e[34m$1\e[0m"
}

# displays a warning message (yellow/orange)
pasc::warning() {
  echo -e "\e[35m$1\e[0m"
}

# displays a line
pasc::line() {
    echo "------------------------------------------"
}

# loads the given config file (which itself is just a bash file that declares
# variables
pasc::loadConfig() {
    pasc::line
    pasc::info "Loading config file: ${1}"

    # check if we have a config file
    if [ ! -f $1 ]; then
        pasc::error "Config not found: ${1}"
        continue
    fi

    source $1
    pasc::info "loaded."
}

# sets the projects mode to TESTNET
pasc::setMode() {
    if [ $1 == "TESTNET" ]; then
        sed -i 's/{\.\$DEFINE TESTNET}/{\$DEFINE TESTNET}/g' config.inc
        sed -i 's/{\$DEFINE PRODUCTION}/{\.\$DEFINE PRODUCTION}/g' config.inc
    fi
}

# Builds the src using lazbuild with the given params
#
#  1. The lazarus project file
#  2. The target operation system
#  3. The target CPU
#  4. The optimization applied
pasc::lazbuild() {
    lazbuild --os=$2 --cpu=$3 --no-write-project "$1"
}

# gets the executable based on the given operting system
#
# Arguments:
#  1. The operating system
#  2. The name of the executable without extension
# Returns:
#  The name of the executable

pasc::getExecutable() {

    if [[ "$1" == "win32" ]] || [[ "$1" == "win64" ]]; then
        echo "$2.exe"
        return
    fi

    if [ "${1}" == "linux" ]; then
        echo $2
        return
    fi

    echo "${1} -> UNKNIOWN"
    exit
    # todo: mac?
}

# Tries to determine the matching libcrypto file depending on the given
# operation system
pasc::getLibCrypto() {

    if [ $1 == "win32" ]; then
        echo "libcrypto-1_1.dll"
        return
    fi

    if [ $1 == "win64" ]; then
        echo "libcrypto-1_1-x64.dll"
        return
    fi

    if [ $1 == "linux" ]; then
        echo "libcrypto.so.1.1"
        return
    fi

    # todo: mac?
}

# will pack the given folder with the resulting name based on the given
# operating system
#
# Arguments:
#
#  1. Build name
#  2. Project slug
#  3. Path
#  4. Operating system
pasc::pack() {

    if [ $4 == "linux" ]; then
        tar -C $CFG_MAIN_TMP_BUILD_DIR -zcf "${3}/${2}_${1}.tar.gz" "pascalcoin_${2}"
        echo "${3}/${2}_${1}.tar.gz"
        return
    fi

    if [ $4 == "win64" ] || [ $4 == "win32" ]; then
        zip -j -r -q "${3}/${2}_${1}.zip" "$CFG_MAIN_TMP_BUILD_DIR/pascalcoin_${2}"
        echo "${3}/${2}_${1}.zip"
        return
    fi
}

# This function will create all the necessary folders and checkout the project
pasc::setup() {

    # first run: if the repo is not checked out yet, we will do so
    if [ ! -d $CFG_MAIN_CHECKOUT_PATH ]; then
        git clone $CFG_MAIN_REPOSITORY $CFG_MAIN_CHECKOUT_PATH
    fi

    # first run: create the builds directory
    if [ ! -d $CFG_MAIN_RELEASES_PATH ]; then
        mkdir $CFG_MAIN_RELEASES_PATH
    fi

    # first run: create the tmp directory
    if [ ! -d $CFG_MAIN_TMP_BUILD_DIR ]; then
        mkdir $CFG_MAIN_TMP_BUILD_DIR
    fi
}

# prepares the git repository
pasc::prepareCheckout() {

    cd $CFG_MAIN_CHECKOUT_PATH
    pasc::info "Fetching remote changes"

    # now we will clean the checked out project completely (latest run) and
    # checkout the master - its as if we have a fresh clone
    git clean -d -x -f
    git checkout .
    git pull --all
    git checkout master
}

# This method will try to build
#
# Arguments:
#  1. The path to the projects config file
#  2. The path to the current build file
#  3. The commit hash (for logging)
#  4. The branch (for logging)
#
pasc::build() {

    PROJECT_CONFIG_FILE=$1
    source "${PROJECT_CONFIG_FILE}"

    BUILD_CONFIG_FILE=$2
    source "${BUILD_CONFIG_FILE}"

    BUILD_TARGET="${CFG_MAIN_TMP_BUILD_DIR}/${PROJ_SLUG}"
    if [ -d "$BUILD_TARGET" ]; then
        rm -rf "${BUILD_TARGET}"
    fi

    mkdir -p $BUILD_TARGET

    cd "${CFG_MAIN_CHECKOUT_PATH}/src"

    # change to testnet if necessary
    pasc::info "Setting mode to ${BUILD_MODE}"
    pasc::setMode "${BUILD_MODE}"

    # now build the executable
    pasc::info "Building.."
    pasc::lazbuild "${PROJ_LPI}" "${BUILD_OPERATING_SYSTEM}" "${BUILD_CPU}" "${BUILD_OPTIMIZATION}" >> "${BUILD_TARGET}/build.log"
    pasc::info "Build done"

    # copy the executable
    cp $(pasc::getExecutable "${BUILD_OPERATING_SYSTEM}" "${PROJ_EXEC}") "${BUILD_TARGET}"

    # copy all additionally configured files
    for PROJ_FILE in "${PROJ_FILES[@]}"
    do
        cp "${PROJ_FILE}" "${BUILD_TARGET}"
    done

    # copy libcrypto
    cp "${CFG_MAIN_HOME}/var/openssl/$(pasc::getLibCrypto "${BUILD_OPERATING_SYSTEM}")" "${BUILD_TARGET}"

    # TODO: really? It seems like sometimes the executables are not there yet,
    # so we will just wait
    sleep 2s

    # Create a build info file
    INFO_FILE="${BUILD_TARGET}/info.log"
    TIMESTAMP=$(date +%s)
    echo "REPOSITORY=$CFG_MAIN_REPOSITORY" >> $INFO_FILE
    echo "BRANCH=$4" >> $INFO_FILE
    echo "COMMIT=$3" >> $INFO_FILE
    echo "BUILD_TIME=${TIMESTAMP}" >> $INFO_FILE
    echo "BUILD_NAME=${BUILD_NAME}" >> $INFO_FILE
    echo "BUILD_OPERATING_SYSTEM=${BUILD_OPERATING_SYSTEM}" >> $INFO_FILE
    echo "BUILD_CPU=${BUILD_CPU}" >> $INFO_FILE
    echo "BUILD_OPTIMIZATION=${BUILD_OPTIMIZATION}" >> $INFO_FILE
    echo "BUILD_MODE=${BUILD_MODE}" >> $INFO_FILE
    echo "PROJ_NAME=${PROJ_NAME}" >> $INFO_FILE
    echo "PROJ_SLUG=${PROJ_SLUG}" >> $INFO_FILE
    echo "PROJ_LPI=${PROJ_LPI}" >> $INFO_FILE
    echo "PROJ_EXEC=${PROJ_EXEC}" >> $INFO_FILE
    echo "PROJ_FILES=${PROJ_FILES}" >> $INFO_FILE
}

# will start the builds
pasc::run() {
    # fetch arguments
    CFG_BRANCH_CONFIG_FILES=("$@")

    # now we will read all active branch configurations
    for CFG_BRANCH_CONFIG_FILE in "${CFG_BRANCH_CONFIG_FILES[@]}"
    do
        # load branch config
        pasc::loadConfig $CFG_BRANCH_CONFIG_FILE
        pasc::info "Branch: ${CFG_BRANCH_NAME}"

        # go to repository and check if the branch exists
        cd $CFG_MAIN_CHECKOUT_PATH

        git clean -d -x -f
        git checkout .

        # check if the branch exists
        LATEST_COMMIT=$(git rev-parse --verify "${CFG_BRANCH_NAME}")

        if [[ $? -ne "0" ]]
        then
            pasc::error "BRANCH $CFG_BRANCH_NAME does not exist in the repository!"
            continue
        fi

        git checkout ${CFG_BRANCH_NAME}

        pasc::info "Latest commit: ${LATEST_COMMIT} in branch ${CFG_BRANCH_NAME}."

        # check if we already built that one, if so we can skip it
        COMMIT_BUILD_PATH="${CFG_MAIN_RELEASES_PATH}/${CFG_BRANCH_NAME}/${LATEST_COMMIT}"
        if [ -d "$COMMIT_BUILD_PATH" ]; then
            pasc::warning "Build for commit $LATEST_COMMIT already exists!"
            continue
        fi

        # create the commit build path
        mkdir -p $COMMIT_BUILD_PATH

        # now loop the build configs and build the projects
        pasc::info "Building commit $LATEST_COMMIT ON BRANCH $CFG_BRANCH_NAME"

        # loop all branch build configs
        for CURRENT_BUILD_CONFIG_FILE in "${CFG_BRANCH_BUILD_CONFIG_FILES[@]}"
        do
            # read build config
            pasc::loadConfig $CURRENT_BUILD_CONFIG_FILE

            if [ $BUILD_ACTIVE == false ]; then
                pasc::warning "${BUILD_NAME} disabled"
                continue
            fi

            # loop the projects to build
            for PROJECT_SLUG in "${BUILD_PROJECTS[@]}"
            do
                pasc::info "Building ${PROJECT_SLUG}"
                pasc::build "${CFG_MAIN_CONFIG_PATH}/projects/${PROJECT_SLUG}.sh" "$CURRENT_BUILD_CONFIG_FILE" "$LATEST_COMMIT" "$CFG_BRANCH_NAME"
                pasc::info "Packing ${PROJECT_SLUG}"
                #pasc::pack "${BUILD_NAME}" "${PROJECT_SLUG}" "${BUILD_TARGET}" "${BUILD_OPERATING_SYSTEM}"
                PACKED_FILE=$(pasc::pack "${BUILD_NAME}" "${PROJECT_SLUG}" "${BUILD_TARGET}" "${BUILD_OPERATING_SYSTEM}")
                cp $PACKED_FILE $COMMIT_BUILD_PATH
                PACKED_FILE_NAME=$(basename $PACKED_FILE)
                cp "${BUILD_TARGET}/info.log" "${COMMIT_BUILD_PATH}/${PACKED_FILE_NAME}.log"
                SHA1=($(sha1sum "${COMMIT_BUILD_PATH}/$PACKED_FILE_NAME"))
                echo $SHA1 > "${COMMIT_BUILD_PATH}/${PACKED_FILE_NAME}.sha1"
            done

            # cleanup TESTNET/PRODUCTION FLAG
            git checkout "${CFG_MAIN_CHECKOUT_PATH}/src/config.inc"

        done
    done
}

pasc::info "PascalCoin build started"

# load the basic config
pasc::loadConfig "${PWD}/config.sh"

# setup folders and project
pasc::setup
pasc::prepareCheckout

# home
cd $CFG_MAIN_HOME

pasc::run "${CFG_MAIN_BRANCH_FILES[@]}"