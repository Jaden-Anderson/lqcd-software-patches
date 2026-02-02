#!/bin/bash
REPO_ROOT=/path/to/an-empty-directory/where/you/would/store/the-source-code
# Modify the above lines first!
main() {
  if [ $3 != "eigen.git" ]
  then
    git clone https://github.com/PX4/eigen.git $2
    if [ $? -ne 0 ]; then return $?; fi
  else
    git -C $2 pull || return $?
  fi
  if [ -f $1/patch.diff ]
  then
    git apply --directory=$2 $1/patch.diff
    if [ $? -ne 0 ]; then return $?; fi
  fi
  echo "Setup succeeded, patches applied."
  echo "Now you may modify the first few lines in 'build.sh' and then run it."
  echo -n $2 > $1/.gitkeepcache
  return 0;
}

setup() {
  if [ $# -gt 2 ]
  then
    echo "ERROR: 'REPO_ROOT' should not contain spaces '${@:2}'"
    return 1
  fi
  if [ "X$2X" = "XX" ]
  then
    echo "ERROR: Missing environment variable; 'REPO_ROOT' should not be set empty!"
    return 1
  fi
  if [ $2 = "/path/to/an-empty-directory/where/you/would/store/the-source-code" ]
  then
    echo "REPO_ROOT=/path/to/an-empty-directory/where/you/would/store/the-source-code"
    echo "# Modify the above lines first!"
    return 1
  fi
  mkdir -p $2 && cd $2 || return $?
  local repo_name=$(git remote get-url origin 2> /dev/null)
  cd - 1> /dev/null
  main $1 $(realpath $2) $(basename .xxx/$repo_name)
  return $?;
}

CURRENT=$0
if [ "X${CURRENT:0:1}X" = "X-X" ]; then CURRENT=${BASH_SOURCE[0]}; fi
if [ "X${CURRENT}X" = "XX" ]; then CURRENT=$(pwd); fi
if [ ! -f $CURRENT/.gitkeepcache ]
then
  echo "ERROR: Cannot locate 'setup.sh'."
  echo "Try executing rather than sourcing it."
  return 1
else
  BASH_CWD=$(dirname $(realpath $CURRENT))
  setup $BASH_CWD $REPO_ROOT
  return $?
fi
