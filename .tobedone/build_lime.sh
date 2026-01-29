#!/bin/bash
LIME_HOME=/path/where/you/would/install/c-lime
cmake .. \
  -DCMAKE_INSTALL_PREFIX=$LIME_HOME \
  -DCMAKE_C_COMPILER=$(which gcc) \
  -DCMAKE_C_FLAGS="-O3 -fPIC"
make -j$(nproc)
make install
if [ "X${CMAKE_PREFIX_PATH}X" = "XX" ]
then
  CMAKE_PREFIX=$LIME_HOME
else
  CMAKE_PREFIX=${LIME_HOME}:${CMAKE_PREFIX_PATH}
fi
export CMAKE_PREFIX_PATH=$CMAKE_PREFIX
mkdir -p $HOME/.local/bin
ln -s $LIME_HOME/bin/lime* $HOME/.local/bin/
