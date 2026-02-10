#!/bin/sh
QUDA_HOME=/path/where/you/would/install/quda
QMP_HOME=/path/where/you/have/installed/qmp
EIGEN_HOME=/path/where/you/have/installed/eigen3
QIO_HOME=/path/where/you/have/installed/qio
# Modify the lines above first!
unset -f _main_ _check_

_main_() {
  if [ "X$1X" = 'XX' ]
  then
    echo "ERROR: Missing environment variable; 'QUDA_HOME' should not be set empty! "
    return 1
  fi
  if [ "X$2X" = 'XX' ]
  then
    echo "ERROR: Missing environment variable; 'QMP_HOME' should not be set empty! "
    return 1
  fi
  if [ "X$3X" = 'XX' ]
  then
    echo "ERROR: Missing environment variable; 'EIGEN_HOME' should not be set empty! "
    return 1
  fi
  if [ "X$4X" = 'XX' ]
  then
    echo "ERROR: Missing environment variable; 'QIO_HOME' should not be set empty! "
    return 1
  fi
  _is_modified='Y'
  if [ "X$1X" = 'X/path/where/you/would/install/qudaX' ]
  then
    echo 'QUDA_HOME=/path/where/you/would/install/quda '
    _is_modified='N'
  fi
  if [ "X$2X" = 'X/path/where/you/have/installed/qmpX' ]
  then
    echo 'QMP_HOME=/path/where/you/have/installed/qmp '
    _is_modified='N'
  fi
  if [ "X$3X" = 'X/path/where/you/have/installed/eigen3X' ]
  then
    echo 'EIGEN_HOME=/path/where/you/have/installed/eigen3 '
    _is_modified='N'
  fi
  if [ "X$4X" = 'X/path/where/you/have/installed/qioX' ]
  then
    echo 'QIO_HOME=/path/where/you/have/installed/qio '
    _is_modified='N'
  fi
  if [ "X${_is_modified}X" != 'XYX' ]
  then
    echo '# Modify the lines above first! '
    return 1
  fi
  { cd -- "$2" && _QMP_PATH=$(pwd) && cd - 1> /dev/null; } || return
  { cd -- "$3" && _EIGEN_PATH=$(pwd) && cd - 1> /dev/null; } || return
  { cd -- "$4" && _QIO_PATH=$(pwd) && cd - 1> /dev/null; } || return
  { mkdir -p -- "$1" && cd -- "$1"; } || return
  _PREFIX_=$(pwd) || return
  REPO_NAME=$(git remote get-url origin 2>/dev/null)
  cd - 1>/dev/null
  return 0
}

_check_() {
  if [ "X$1X" = 'XX' ]; then return 1; fi
  cd -- "${1%/*}" 2>/dev/null || return
  if [ ! -f build.sh ]; then return 1; fi
  if [ ! -f .gitkeepcache ]; then return 1; fi
  CURRENT=$(pwd) || return
  cd - 1>/dev/null
  return 0
}

unset CURRENT REPO_HOME REPO_NAME _PREFIX_
_check_ "$0" || _check_ "${BASH_SOURCE[0]}" || _check_ "./." || {
 eval 'echo ${.sh.file}' 1>/dev/null 2>&1 && _check_ "${.sh.file}"
} || {
 eval 'echo ${(%):-%x}' 1>/dev/null 2>&1 && _check_ "${(%):-%x}"
}
if [ "X${CURRENT}X" = 'XX' ]
then
  echo "ERROR: Cannot locate this script 'build.sh'. "
  echo 'Try executing it, rather than sourcing it. '
  return 1
fi
REPO_HOME=$(cat "$CURRENT/.gitkeepcache")
if [ "X${REPO_HOME}X" = 'XX' ]
then
  echo "ERROR: Run 'setup.sh' first! "
  return 1
fi
_main_ "$QUDA_HOME" "$QMP_HOME" "$EIGEN_HOME" "$QIO_HOME" || return

_is_install='Y'
if [ "X${REPO_NAME##*.}X" = 'X.gitX' ]
then
  echo "WARNING: 'QUDA_HOME' is in the repository '$REPO_NAME', which is not recommended."
  printf 'Are you sure to install QUDA in %s ([No]/Yes)? ' "'$_PREFIX_'"
  read -r _user_option
  _is_install=$(printf '%s' "$_user_option" | tr '[:lower:]' '[:upper:]')
fi
if [ "X${_is_install%ES}X" != 'XYX' ]; then return 0; fi
if [ ! -f "$REPO_HOME/CMakeLists.txt" ]
then
  echo "ERROR: File not found '$REPO_HOME/CMakeLists.txt'. "
  echo 'Something went wrong! Aborted. '
  return 1
fi
_QMPIO_PATH="${_QMP_PATH}:${_QIO_PATH}${CMAKE_PREFIX_PATH:+:}"
CMAKE_PREFIX_PATH="$_QMPIO_PATH$CMAKE_PREFIX_PATH"
cmake -Wno-dev \
 -S "$REPO_HOME" \
 -B "$REPO_HOME/build" \
 -DCMAKE_INSTALL_PREFIX="$_PREFIX_" \
 -DQMP_DIR="$_QMP_PATH/lib/cmake/QMP" \
 -DEIGEN_INCLUDE_DIR="$_EIGEN_PATH/include/eigen3" \
 -DQIO_DIR="$_QMP_PATH/lib/cmake/QIO" \
 -DCMAKE_BUILD_TYPE=RELEASE \
 -DQUDA_BUILD_SHAREDLIB=ON \
 -DQUDA_TARGET_TYPE=CUDA \
 -DQUDA_DIRAC_LAPLACE=ON \
 -DQUDA_DIRAC_COVDEV=ON \
 -DQUDA_DIRAC_WILSON=ON \
 -DQUDA_DIRAC_CLOVER=ON \
 -DQUDA_DIRAC_STAGGERED=ON \
 -DQUDA_DIRAC_DOMAIN_WALL=OFF \
 -DQUDA_DIRAC_TWISTED_MASS=OFF \
 -DQUDA_DIRAC_TWISTED_CLOVER=OFF \
 -DQUDA_CLOVER_DYNAMIC=OFF \
 -DQUDA_CLOVER_RECONSTRUCT=OFF \
 -DQUDA_CLOVER_CHOLESKY_PROMOTE=ON \
 -DQUDA_MULTIGRID=ON \
 -DQUDA_ENABLE_MMA=ON \
 -DQUDA_MULTIGRID_DSLASH_PROMOTE=ON \
 -DQUDA_MPI=OFF \
 -DQUDA_QMP=ON \
 -DQUDA_QIO=ON \
 -DQUDA_ARPACK=OFF \
 -DQUDA_USE_EIGEN=ON \
 -DQUDA_DOWNLOAD_EIGEN=OFF \
 -DQUDA_DOWNLOAD_USQCD=OFF \
 -DQUDA_DOWNLOAD_NVSHMEM=OFF \
 -DQUDA_INTERFACE_QDP=ON \
 -DQUDA_INTERFACE_MILC=OFF \
 -DQUDA_INTERFACE_CPS=OFF \
 -DQUDA_INTERFACE_BQCD=OFF \
 -DQUDA_INTERFACE_TIFR=OFF \
 -DQUDA_INTERFACE_OPENQCD=OFF \
 -DQUDA_SPACK_BUILD=OFF \
 -DQUDA_BACKWARDS=OFF \
 -DQUDA_PRECISION=14 \
 -DQUDA_RECONSTRUCT=7 \
 -DQUDA_CXX_STANDARD=17 \
 -DQUDA_MAX_MULTI_BLAS_N=8 \
 -DCMAKE_C_COMPILER="$(command -v gcc)" \
 -DCMAKE_CXX_COMPILER="$(command -v g++)" \
 -DCMAKE_CUDA_COMPILER="$(command -v nvcc)" \
 -DCMAKE_C_FLAGS='-O3 -fPIC' \
 -DCMAKE_CXX_FLAGS='-O3 -fPIC'
if [ $? -ne 0 ]; then return; fi
_nproc=$(( $(nproc) / 3 ))
make -C "$REPO_HOME/build" -j$_nproc || return
make -C "$REPO_HOME/build" install || return
