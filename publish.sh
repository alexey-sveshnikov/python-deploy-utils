#!/bin/sh

PACKAGE='futubank-deploy-utils'
REPOSITORY_HOST='repo0'

#version=`head -n1 debian/changelog | cut -f2 -d\( | cut -f1 -d\)`
version=`date +"%Y-%m-%d--%H-%M" | tr -d "\n"`

pdebuild --buildresult .. --debbuildopts '-us -uc'

deb_file=${PACKAGE}_${version}_amd64.deb

scp ../$deb_file $REPOSITORY_HOST:/tmp
ssh $REPOSITORY_HOST "sudo -u repo -H aptly repo add futubank-dev /tmp/$deb_file"
ssh $REPOSITORY_HOST "sudo -u repo -H aptly publish update main futubank-dev"
