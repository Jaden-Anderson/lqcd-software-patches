#!/usr/bin/env bash
QIO_HOME=/path/where/you/would/install/qio
LIME_HOME=/path/where/you/have/installed/c-lime
# Modify the lines above first!
main() {
  local home=$(realpath $2)
  local lime=$(realpath $3)
  local option is_install=yes
  if [ "X${4:0-4}X" = "X.gitX" ]
  then
    echo "WARNING: 'QIO_HOME' is in the repository '$4', which is not recommended."
    read -p "Are you sure to install QIO in '$home' ([no]/yes)? " option
    case "${option,,}" in
      y|yes) unset option;;
      *) unset is_install;;
    esac
  fi
  if [ ! $is_install ]; then return 0; fi
  if [ ! -f $1/CMakeLists.txt ]
  then
    echo "ERROR: Cannot find file '$1/CMakeLists.txt'."
    return 1
  fi
  cmake -B $1/build -S $1 \
  -DCMAKE_INSTALL_PREFIX=$home \
  -DCLime_DIR=$lime \
  -DCMAKE_BUILD_TYPE=Release \
  -DQIO_ENABLE_PARALLEL_BUILD=ON \
  -DQIO_ENABLE_PARALLEL_IO=ON \
  -DQIO_ENABLE_QMP_ROUTE=ON \
  -DQIO_ENABLE_OUTPUT_BUFFERING=ON \
  -DQIO_BUILD_TESTS=ON \
  -DQIO_ENABLE_SANITIZERS=OFF \
  -DCMAKE_C_COMPILER=$(which gcc) \
  -DCMAKE_C_FLAGS="-O3 -fPIC"
  if [ $? -ne 0 ]; then return $?; fi
  make -C $1/build -j$(nproc) || return $?
  make -C $1/build install || return $?
  local prefix
  if [ "X${CMAKE_PREFIX_PATH}X" = "XX" ]
  then
    prefix=$home
  else
    prefix=${home}:${CMAKE_PREFIX_PATH}
  fi
  export CMAKE_PREFIX_PATH=$prefix
  return 0;
}

build() {
  if [ $# -gt 3 ]
  then
    echo "ERROR: 'LIME_HOME' should not contain spaces '${@:3}'"
    return 1
  fi
  if [ "X$3X" = "XX" ]
  then
    echo "ERROR: Missing environment variable; 'LIME_HOME' should not be set empty!"
    return 1
  fi
  local code=0
  if [ $2 = "/path/where/you/would/install/qio" ]
  then
    echo "QIO_HOME=/path/where/you/would/install/qio"
    code=$(expr $code + 1)
  fi
  if [ $3 = "/path/where/you/have/installed/c-lime" ]
  then
    echo "LIME_HOME=/path/where/you/have/installed/c-lime"
    code=$(expr $code + 1)
  fi
  if [ $code -ne 0 ]
  then
    echo "# Modify the lines above first!"
    return $code
  fi
  cd $3 && cd - 1> /dev/null || return $?
  mkdir -p $2 && cd $2 || return $?
  local repo_name=$(git remote get-url origin 2> /dev/null)
  cd - 1> /dev/null
  main $1 $2 $3 $(basename .xxx/$repo_name)
  return $?;
}

check() {
  if [ $# -gt 2 ]
  then
    echo "ERROR: 'QIO_HOME' should not contain spaces '${@:2}'"
    return 1
  fi
  if [ "X$2X" = "XX" ]
  then
    echo "ERROR: Missing environment variable; 'QIO_HOME' should not be set empty!"
    return 1
  fi
  return 0;
}

CURRENT=$0
if [ "X${CURRENT:0:1}X" = "X-X" ]; then CURRENT=${BASH_SOURCE[0]}; fi
if [ "X${CURRENT}X" = "XX" ]; then CURRENT=$(pwd); fi
if [ ! -f $CURRENT/.gitkeepcache ]
then
  echo "ERROR: Cannot locate 'build.sh'."
  echo "Try executing rather than sourcing it."
  return 1
else
  BASH_CWD=$(dirname $(realpath $CURRENT))
  REPO_ROOT=$(cat $BASH_CWD/.gitkeepcache)
  if [ "X${REPO_ROOT}X" = "XX" ]
  then
    echo "ERROR: Run 'setup.sh' first!"
    return 1
  fi
  echo -n > $BASH_CWD/.gitkeepcache
  mkdir -p $REPO_ROOT/build || return $?
  check $REPO_ROOT $QIO_HOME || return $?
  build $REPO_ROOT $QIO_HOME $LIME_HOME
  return $?
fi
