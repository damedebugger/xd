#!/bin/bash

source scripts/config-vars.sh

# start from a clean $OUTBASEDIR
if [ -d ${OUTBASEDIR} ] ; then
    BACKUPDIR=products/`date +"%Y%m%d-%H%M%S.%N"`
    echo ${OUTBASEDIR} already exists!  moving to $BACKUPDIR
    mv ${OUTBASEDIR} ${BACKUPDIR}
fi

mkdir -p ${OUTBASEDIR}

export LOGFILE=${OUTBASE}-pipeline.log 

exec > >(tee -i ${LOGFILE}) 2>&1

/bin/bash scripts/01-full-pipeline.sh

aws s3 cp --region ${REGION} ${LOGFILE} ${S3PRIV}/logs/

scripts/send-email.py $ADMIN_EMAIL "execution logs for $TODAY" ${LOGFILE}

