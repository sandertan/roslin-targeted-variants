#!/bin/bash

# load config
source ./settings.sh

if [ -z $PRISM_BIN_PATH ] || [ -z $PRISM_INPUT_PATH ]
then
    echo "Some necessary paths are not correctly configured."
    echo "PRISM_BIN_PATH=${PRISM_BIN_PATH}"
    echo "PRISM_INPUT_PATH=${PRISM_INPUT_PATH}"
    exit 1
fi

usage()
{
cat << EOF

USAGE: `basename $0` [options]

OPTIONS:

   -u      Username you want to configure a workplace for
   -f      Overwrite workspace even if it exists

EXAMPLE:

   `basename $0` -u chunj

EOF
}

USE_SINGLE_MACHINE_EXAMPLE=0
FORCE_OVERWRITE=0

while getopts “u:sfh” OPTION
do
    case $OPTION in
        u) USER_ID=$OPTARG ;;
        s) USE_SINGLE_MACHINE_EXAMPLE=1 ;;
        f) FORCE_OVERWRITE=1 ;;
        h) usage; exit 1 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z $USER_ID ]
then
    usage
    exit 1
fi

if [ `whoami` != "$USER_ID" ]
then
    echo "You can only run this from your own account (`whoami` != ${USER_ID})"
    echo "Aborted."
    exit 1
fi

HOME_DIR=$HOME

if [ -d "${PRISM_INPUT_PATH}/${USER_ID}" ] && [ "${FORCE_OVERWRITE}" -eq 0 ]
then
    echo "Your workspace already exists: ${PRISM_INPUT_PATH}/${USER_ID}"
    echo "Aborted."
    exit 1
fi

# create user directory
mkdir -p ${PRISM_INPUT_PATH}/${USER_ID}

# copy jumpstart exampels
tar xzf ${PRISM_BIN_PATH}/bin/setup/examples.tgz -C ${PRISM_INPUT_PATH}/${USER_ID} --strip-components 1

if [ "$USE_SINGLE_MACHINE_EXAMPLE" -eq 1 ]
then
    find ${PRISM_INPUT_PATH}/${USER_ID}/ -name "run-example.sh" | xargs -I {} sed -i "s/lsf/singleMachine/g" {}
fi

# .roslin
mkdir -p $HOME_DIR/.roslin

# add under .roslin the scripts & settings to be loaded upon user login
cp ./settings.sh $HOME_DIR/.roslin/
echo "PATH=\$PATH:${PRISM_BIN_PATH}/bin/sing" > $HOME_DIR/.roslin/sing.sh
echo "PATH=\$PATH:${PRISM_BIN_PATH}/bin/prism-runner" > ~/.roslin/prism-runner.sh

# append -S 1 to TOIL_LSF_ARGS (IGOWEB-459)
if [[ "${TOIL_LSF_ARGS}" != *"-S 1"* ]]
then
    echo "export TOIL_LSF_ARGS='${TOIL_LSF_ARGS} -S 1'" > ~/.roslin/toil-lsf-args.sh
fi

cp $HOME_DIR/.profile $HOME_DIR/.profile.bak

settings_found=`grep "# ROSLIN.SETTINGS\$" $HOME_DIR/.profile`
if [ -z "$settings_found" ]
then
    echo "for file in $HOME_DIR/.roslin/*.sh; do source \$file; done  # ROSLIN.SETTINGS" >> $HOME_DIR/.profile
fi

cat << "EOF"

 ______     ______     ______     __         __     __   __                  
/\  == \   /\  __ \   /\  ___\   /\ \       /\ \   /\ "-.\ \                 
\ \  __<   \ \ \/\ \  \ \___  \  \ \ \____  \ \ \  \ \ \-.  \                
 \ \_\ \_\  \ \_____\  \/\_____\  \ \_____\  \ \_\  \ \_\\"\_\               
  \/_/ /_/   \/_____/   \/_____/   \/_____/   \/_/   \/_/ \/_/               
 ______   __     ______   ______     __         __     __   __     ______    
/\  == \ /\ \   /\  == \ /\  ___\   /\ \       /\ \   /\ "-.\ \   /\  ___\   
\ \  _-/ \ \ \  \ \  _-/ \ \  __\   \ \ \____  \ \ \  \ \ \-.  \  \ \  __\   
 \ \_\    \ \_\  \ \_\    \ \_____\  \ \_____\  \ \_\  \ \_\\"\_\  \ \_____\ 
  \/_/     \/_/   \/_/     \/_____/   \/_____/   \/_/   \/_/ \/_/   \/_____/ 
                                                                             

 Roslin Pipeline

EOF

echo "Your workspace: ${PRISM_INPUT_PATH}/${USER_ID}"
echo "You're all set. Log out and log back in."
echo