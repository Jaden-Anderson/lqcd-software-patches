#!/bin/bash
EIGEN_HOME=/path/where/you/would/install/eigen3
# Modify the lines above first!
main() {
  local home=$(realpath $2)
  local option is_install=yes
  if [ "X${3:0-4}X" = "X.gitX" ]
  then
    echo "WARNING: 'EIGEN_HOME' is in the repository '$3', which is not recommended."
    read -p "Are you sure to install Eigen3 in '$home' (N/y)?" option
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
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=OFF \
    -DEIGEN_BUILD_DEMOS=OFF \
    -DEIGEN_BUILD_DOC=OFF \
    -DEIGEN_BUILD_TESTING=OFF \
    -DEIGEN_BUILD_PKGCONFIG=ON \
    -DEIGEN_BUILD_BTL=OFF \
    -DEIGEN_BUILD_BLAS=OFF \
    -DEIGEN_BUILD_LAPACK=OFF \
    -DEIGEN_BUILD_SPBENCH=OFF \
    -DEIGEN_BUILD_AOCL_BENCH=OFF \
    -DCMAKE_C_COMPILER=$(which gcc) \
    -DCMAKE_CXX_COMPILER=$(which g++)
  make -C $1/build install || return $?
  local prefix
  if [ "X${CMAKE_PREFIX_PATH}X" = "XX" ]
  then
    prefix=$home
  else
    prefix=${home}:${CMAKE_PREFIX_PATH}
  fi
  export CMAKE_PREFIX_PATH=$prefix
  local lib="$home/lib/cmake"
  local src="share/eigen3/cmake"
  mkdir -p $lib && cd $lib || return $?
  ln -s ../../$src eigen3
  cd - > /dev/null
  return 0;
}

build() {
  if [ $# -gt 2 ]
  then
    echo "ERROR: 'EIGEN_HOME' should not contain spaces '${@:2}'"
    return 1
  fi
  if [ $2 = "/path/where/you/would/install/eigen3" ]
  then
    echo "EIGEN_HOME=/path/where/you/would/install/eigen3"
    echo "# Modify the above lines first!"
    return 1
  fi
  mkdir -p $2 && cd $2 || return $?
  local repo_name=$(git remote get-url origin 2> /dev/null)
  cd - > /dev/null
  main $1 $2 $(basename .xxx/$repo_name)
  return $?;
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
  build $REPO_ROOT $EIGEN_HOME
  return $?
fi
