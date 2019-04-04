#!/bin/bash
# Run command: ash /volume1/Private/Scripts/backup/sync.sh

# ****************************************
# SYNOLOGY REMOTE FOLDERS SYNCHRONIZATION
# ****************************************
# By Krzysztof Przygoda
# http://www.iknowsomething.com
# 2015-09-15
# ****************************************

# Setup

BASEDIR=$(dirname $0)
LOG_FILE="${BASEDIR}/sync.log"
BACKUPS_SCRIPT="${BASEDIR}/sync-backups.sh"

EXCLUDE_FILE="${BASEDIR}/sync-exclude-list.txt"
# Exclude files or folders example:
# @eaDir/       - Synology thumbnails' dirs
# #recycle      - Synology recycle bin
# .DS_Store     - Apple trash
# .apdisk       - Apple trash
# .*            - All Hidden files
# .*/           - All Hidden dirs

# Main rsync function definition

sync () {
    # Prepare log
    echo " " >>${LOG_FILE}
    echo "************************************************************************" >>${LOG_FILE}
    echo "Backing up: ${SOURCE} to: ${DESTINATION}">>${LOG_FILE}
    echo "************************************************************************" >>${LOG_FILE}
    echo " " >>${LOG_FILE}
    SYNC='rsync -av --delete --exclude-from="'${EXCLUDE_FILE}'" "'${SOURCE}'" "'${DESTINATION}'" >>"'${LOG_FILE}'"'
    echo "Using: ${SYNC}" >>${LOG_FILE}
    echo " ">>${LOG_FILE}

    # Create destination's dirs structure if not exists.
    # Param -p: No error if exists; make parent directories as needed.
    mkdir -p "${DESTINATION}" >>${LOG_FILE}

    # Start rsync
    #${SYNC}
    #rsync -av --exclude="@eaDir" --delete "${SOURCE}" "${DESTINATION}" >>${LOG_FILE}
    #rsync -av --delete --exclude-from="${EXCLUDE_FILE}" "${1}" "${2}" >>${LOG_FILE}
    rsync -av --delete --exclude-from="${EXCLUDE_FILE}" "${SOURCE}" "${DESTINATION}" >>${LOG_FILE}
}

# Start syncing

echo "Started: `date`" >${LOG_FILE} # ... and create log file
echo "Script executed from: ${PWD}" >>${LOG_FILE}
echo "Script location: ${BASEDIR}" >>${LOG_FILE}
echo "Excluded list:" >>${LOG_FILE}
cat ${EXCLUDE_FILE} >>${LOG_FILE}

#cd ${BASEDIR}
source ${BACKUPS_SCRIPT}