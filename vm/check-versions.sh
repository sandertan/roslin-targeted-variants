#!/bin/bash

# for the time being, sudo su is required
if [ "`whoami`" != 'root' ]
then
    echo "Run sudo su first."
    exit 1
fi

version_file="/var/log/prism-software-versions.txt"

write()
{
    echo $1 | sudo tee --append ${version_file}
}

# $1 name
# $2 command to run to get version
check()
{
    version=`$2 2>&1`
    write "$1 : $version"
}

sudo rm -rf $version_file

check "python" "python --version"
check "pip" "pip --version"
check "docker" "docker --version"
check "singularity" "singularity --version"

# cmo works a bit different, so...
# need cmo_resources.json in order to import cmo.
cmo_version=`CMO_RESOURCE_CONFIG="/usr/local/bin/cmo-gxargparse/cmo/cmo/data/cmo_resources.json" python -c "import cmo; print cmo.__version__"`
write "cmo : $cmo_version"