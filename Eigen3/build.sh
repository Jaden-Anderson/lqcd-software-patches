#!/bin/bash
EIGEN_HOME=/path/where/you/would/install/eigen3
# Modify the lines above first!
main() {
  if [ $(basename $1) != 'build' ]
  then
    echo "ERROR: Cannot locate '$EIGEN_REPO_ROOT/build'."
    echo "Try switching the current directory there."
    return 1
  fi
  SRC_DIR=$(dirname $1)
  PREFIX=$(realpath $2)
  if [ ! -f $SRC_DIR/CMakeLists.txt ]
  then
    echo "ERROR: Cannot find file '$SRC_DIR/CMakeLists.txt'."
    return 1
  fi
  cmake $SRC_DIR \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
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
  make install
  if [ $? -ne 0 ]
  then
    return $?
  fi
  if [ "X${CMAKE_PREFIX_PATH}X" = "XX" ]
  then
    CMAKE_PREFIX=$PREFIX
  else
    CMAKE_PREFIX=${PREFIX}:${CMAKE_PREFIX_PATH}
  fi
  export CMAKE_PREFIX_PATH=$CMAKE_PREFIX
  mkdir -p $PREFIX/lib/cmake
  cd $PREFIX/lib/cmake
  ln -s ../../share/eigen3/cmake eigen3
  cd - > /dev/null
  return 0
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
  if [ ! -d $(dirname $2) ]
  then
    echo "ERROR: No such directory '$(dirname $2)'."
    return 1
  fi
  main $1 $2
}

CURRENT=${BASH_SOURCE[0]}
if [ "X${CURRENT}X" = "XX" ]
then
  CURRENT=$0
fi
if [ "X${CURRENT:0:1}X" = "X-X" ]
then
  echo "ERROR: Cannot locate 'build.sh'."
  echo "Try executing rather than sourcing it."
else
  build $(dirname $(realpath $CURRENT)) $EIGEN_HOME
fi
