#!/bin/sh
EIGEN_HOME=/path/where/you/would/install/eigen3
# Modify the lines above first!
unset -f _main_ _check_

_main_() {
  if [ "X$1X" = 'XX' ]
  then
    echo "ERROR: Missing environment variable; 'EIGEN_HOME' should not be set empty! "
    return 1
  fi
  if [ "X$1X" = 'X/path/where/you/would/install/eigen3X' ]
  then
    echo 'EIGEN_HOME=/path/where/you/would/install/eigen3 '
    echo '# Modify the above lines first! '
    return 1
  fi
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
_main_ "$EIGEN_HOME" || return

_is_install='Y'
if [ "X${REPO_NAME##*.}X" = 'X.gitX' ]
then
  echo "WARNING: 'EIGEN_HOME' is in the repository '$REPO_NAME', which is not recommended."
  printf 'Are you sure to install Eigen3 in %s ([No]/Yes)? ' "'$_PREFIX_'"
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
cmake -Wno-dev \
 -S "$REPO_HOME" \
 -B "$REPO_HOME/build" \
 -DBUILD_TESTING=OFF \
 -DCMAKE_INSTALL_PREFIX="$_PREFIX_" \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_VERBOSE_MAKEFILE=OFF \
 -DEIGEN_BUILD_PKGCONFIG=ON \
 -DEIGEN_BUILD_BTL=OFF \
 -DCMAKE_C_COMPILER="$(command -v gcc)" \
 -DCMAKE_CXX_COMPILER="$(command -v g++)"
if [ $? -ne 0 ]; then return; fi
make -C "$REPO_HOME/build" install || return
if [ -d "$_PREFIX_/share/eigen3/cmake" ]
then
  mkdir -p "$_PREFIX_/lib/cmake" &&
  cd "$_PREFIX_/lib/cmake" ||
  return
  ln -s ../../share/eigen3/cmake eigen3
  cd - 1>/dev/null
fi
_PREFIX_="$_PREFIX_${CMAKE_PREFIX_PATH:+:}"
CMAKE_PREFIX_PATH="$_PREFIX_$CMAKE_PREFIX_PATH"
