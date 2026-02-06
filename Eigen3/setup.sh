#!/bin/sh
REPO_ROOT=/path/to/an-empty-directory/where/you/would/store/the-source-code
# Modify the above lines first!
unset -f _main_ _check_

_main_() {
  if [ "X$1X" = 'XX' ]
  then
    echo "ERROR: Missing environment variable; 'REPO_ROOT' should not be set empty! "
    return 1
  fi
  if [ "X$1X" = 'X/path/to/an-empty-directory/where/you/would/store/the-source-codeX' ]
  then
    echo 'REPO_ROOT=/path/to/an-empty-directory/where/you/would/store/the-source-code '
    echo '# Modify the above lines first! '
    return 1
  fi
  echo "X$1X" | grep '[[:space:]]' 1>/dev/null
  if [ $? -eq 0 ]
  then
    echo "ERROR: 'REPO_ROOT' should not contain space characters '$1'. "
    return 1
  fi
  { mkdir -p -- "$1" && cd -- "$1" ; } || return
  REPO_HOME=$(pwd) || return
  REPO_NAME=$(git remote get-url origin 2>/dev/null)
  cd - 1>/dev/null
  return 0
}

_check_() {
  if [ "X$1X" = 'XX' ]; then return 1; fi
  cd -- "${1%/*}" 2>/dev/null || return
  if [ ! -f setup.sh ]; then return 1; fi
  if [ ! -f .gitkeepcache ]; then return 1; fi
  CURRENT=$(pwd) || return
  cd - 1>/dev/null
  return 0
}

unset CURRENT REPO_HOME REPO_NAME
_check_ "$0" || _check_ "${BASH_SOURCE[0]}" || _check_ "./." || {
 eval 'echo ${.sh.file}' 1>/dev/null 2>&1 && _check_ "${.sh.file}"
} || {
 eval 'echo ${(%):-%x}' 1>/dev/null 2>&1 && _check_ "${(%):-%x}"
}
if [ "X${CURRENT}X" = 'XX' ]
then
  echo "ERROR: Cannot locate this script 'setup.sh'. "
  echo 'Try executing it, rather than sourcing it. '
  return 1
fi
printf '' > "$CURRENT/.gitkeepcache" || return
_main_ "$REPO_ROOT" || return

REPO_URL='https://github.com/PX4/eigen.git'
if [ "X${REPO_NAME##*/}X" = 'Xeigen.gitX' ]
then
  git -C "$REPO_HOME" pull ||
  return
else
  git clone "$REPO_URL" "$REPO_HOME" ||
  return
fi
mkdir -p "$REPO_HOME/build" || return
if [ -f "$CURRENT/patch.diff" ]
then
  git -C "$REPO_HOME" \
   apply --verbose \
   "$CURRENT/patch.diff" ||
  return
  git -C "$REPO_HOME" \
   add "$REPO_HOME" &&
  git -C "$REPO_HOME" \
   -c user.name='Jaden-Anderson' \
   -c user.email='wangtx@ihep.ac.cn' \
   commit -m 'Apply patches' 1>/dev/null ||
  return
fi
echo 'Setup succeeded, patches applied (if any). '
echo "Now you may modify the first few lines in 'build.sh' and then run it. "
printf '%s' "$REPO_HOME" > "$CURRENT/.gitkeepcache"
