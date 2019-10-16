export PROFILE_PATH=$SCRIPTDIR
export SHELLPACK_TOPLEVEL=$SCRIPTDIR
export SHELLPACK_STAP=$SHELLPACK_TOPLEVEL/stap-scripts
export SHELLPACK_TEST_MOUNT=$SCRIPTDIR/work/testdisk
export SHELLPACK_SOURCES=$SCRIPTDIR/work/sources
export SHELLPACK_TEMP=$SCRIPTDIR/work/tmp/$$
export SHELLPACK_DATA=$SHELLPACK_TEST_MOUNT/data
export SHELLPACK_INCLUDE=$SCRIPTDIR/shellpacks
export SHELLPACK_LOG_BASE_SUBDIR=work/log
export SHELLPACK_LOG_BASE=$SCRIPTDIR/$SHELLPACK_LOG_BASE_SUBDIR
export LINUX_GIT=/home/mel/git-public/linux-2.6
export WEBROOT=http://mcp/mmtests-mirror
export SSHROOT=`echo $WEBROOT | sed -e 's/http:\/\//ssh:\/\/root@/'`/public_html

# Compiler flags
export MMTESTS_BUILD_CFLAGS="-O2"
export MMTESTS_BUILD_CPPFLAGS="-O2"
export MMTESTS_BUILD_LDFLAGS=
