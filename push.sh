#!/bin/sh
set -ex

HOST=$1
PACKAGE='futubank-deploy-utils'

echo "Deploying to $HOST"

version=`head -n1 debian/changelog | cut -f2 -d\( | cut -f1 -d\)`
deb_file=${PACKAGE}_${version}_amd64.deb

HOME=`ssh $HOST pwd`

pdebuild --buildresult .. --debbuildopts '-us -uc' \
&& ssh $HOST 'mkdir -p repo' \
&& ssh $HOST 'sudo sh -c "echo \"deb file:$HOME/repo /\" > /etc/apt/sources.list.d/local.list"' \
&& scp ../$deb_file $HOST:repo \
&& ssh $HOST 'cd repo && dpkg-scanpackages . /dev/null | gzip -9 > Packages.gz' \
&& ssh $HOST 'sudo apt-get update -o Dir::Etc::sourcelist="sources.list.d/local.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"' \
&& ssh $HOST "sudo dpkg -P $PACKAGE; sudo apt-get install -y --force-yes $PACKAGE"
