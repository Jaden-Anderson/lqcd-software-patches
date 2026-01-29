#!/bin/bash
REPO_ROOT=/path/to/an-empty-directory/where/you/would/store/the-source-code
# Modify the above lines first!
main() {
  git clone https://github.com/PX4/eigen.git $2
  if [ $? -ne 0 ]
  then
    return $?
  fi
  if [ ! -f $2/CMakeLists.txt ]
  then
    echo "ERROR: Source code cloned, but 'CMakeLists.txt' not found."
    return 1
  fi
  mkdir $2/build
  cd $2/build
  cp $1/build.sh ./
  if [ -f $1/patch.diff ]
  then
    git apply --directory=$2 $1/patch.diff
  fi
  echo "Setup succeeded, patches applied."
  echo "Now you may modify the first few lines in '$2/build/build.sh' and then run it."
  export EIGEN_REPO_ROOT=$2
  return 0
}

setup() {
  if [ $# -gt 2 ]
  then
    echo "ERROR: 'REPO_ROOT' should not contain spaces '${@:2}'"
    return 1
  fi
  if [ $2 = "/path/to/an-empty-directory/where/you/would/store/the-source-code" ]
  then
    echo "REPO_ROOT=/path/to/an-empty-directory/where/you/would/store/the-source-code"
    echo "# Modify the above lines first!"
    return 1
  fi
  if [ ! -d $(dirname $2) ]
  then
    echo "ERROR: No such directory '$(dirname $2)'."
    return 1
  fi
  main $1 $(realpath $2)
}

CURRENT=${BASH_SOURCE[0]}
if [ "X${CURRENT}X" = "XX" ]
then
  CURRENT=$0
fi
if [ "X${CURRENT:0:1}X" = "X-X" ]
then
  echo "ERROR: Cannot locate 'setup.sh'."
  echo "Try executing rather than sourcing it."
else
  setup $(dirname $(realpath $CURRENT)) $REPO_ROOT
fi
