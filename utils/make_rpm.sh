#!/bin/bash

RPMBUILD_DIR="${HOME}/rpmbuild/"

BUILD_DIR="$RPMBUILD_DIR/BUILD"
echo "Cleaning $BUILD_DIR"
rm -rf $BUILD_DIR
echo "Removing $RPMBUILD_DIR/createrepo_c.spec"
rm -f $RPMBUILD_DIR/createrepo_c.spec


if [ $# -lt "1"  -o $# -gt "2" ]
then
    echo "Usage: `basename $0` <root_project_dir> [--git]"
    exit 1
fi

USE_GIT=""

if [ $# -eq "2" ]
then
    if [ $2 != "--git" ]
    then
        echo -e "Bad second argument\nUsage: `basename $0` <root_project_dir> [--git]"
        exit 1
    fi
    USE_GIT="1"
fi


PREFIX="$1/"

MY_DIR=`dirname $0`
MY_DIR="$MY_DIR/"


if [ ! -d "$RPMBUILD_DIR" ]; then
    echo "rpmbuild dir $RPMBUILD_DIR doesn't exist!"
    echo "init rpmbuild dir with command: rpmdev-setuptree"
    echo "(Hint: Package group @development-tools and package fedora-packager)"
    exit 1
fi


if [ $USE_GIT ]; then
    echo "> Making tarball from GIT.."
    $MY_DIR/make_tarball_from_git.sh > /dev/null
else
    echo "> Making tarball .."
    $MY_DIR/make_tarball.sh $PREFIX > /dev/null
fi

if [ ! $? == "0" ]; then
    echo "Error while making tarball"
    exit 1
fi
echo "Tarball done"

echo "> Copying tarball and .spec file into the $RPMBUILD_DIR .."
cp $PREFIX/createrepo_c-*.tar.xz $RPMBUILD_DIR/SOURCES/
if [ ! $? == "0" ]; then
    echo "Error while: cp $PREFIX/createrepo_c-*.tar.xz $RPMBUILD_DIR/SOURCES/"
    exit 1
fi

cp $PREFIX/createrepo_c.spec $RPMBUILD_DIR/SPECS/
if [ ! $? == "0" ]; then
    echo "Error while: cp $PREFIX/createrepo_c.spec $RPMBUILD_DIR/SPECS/"
    exit 1
fi
echo "Copying done"

echo "> Starting rpmbuild .."
rpmbuild -ba $RPMBUILD_DIR/SPECS/createrepo_c.spec
if [ ! $? == "0" ]; then
    echo "Error while: rpmbuild -ba $RPMBUILD_DIR/SPECS/createrepo_c.spec"
    exit 1
fi
echo "rpmbuild done"

echo "> Cleanup .."
rpmbuild --clean $RPMBUILD_DIR/SPECS/createrepo_c.spec
echo "Cleanup done"

echo "> Moving rpms and srpm .."
mv --verbose $RPMBUILD_DIR/SRPMS/createrepo_c-*.src.rpm $PREFIX/.
mv --verbose $RPMBUILD_DIR/RPMS/*/createrepo_c-*.rpm $PREFIX/.
echo "Moving done"

echo "All done!"