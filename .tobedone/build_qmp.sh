#!/bin/bash
QMP_HOME=/path/where/you/would/install/qmp
cmake .. \
  -DCMAKE_INSTALL_PREFIX=$QMP_HOME \
  -DCMAKE_BUILD_TYPE=Release \
  -DQMP_MPI=ON \
  -DQMP_PROFILING=OFF \
  -DQMP_TIMING=OFF \
  -DQMP_EXTRA_DEBUG=OFF \
  -DQMP_TESTING=ON \
  -DQMP_BUILD_DOCS=OFF \
  -DQMP_ENABLE_SANITIZERS=OFF \
  -DQMP_USE_DMALLOC=OFF \
  -DQMP_BGQ=OFF \
  -DQMP_BGSPI=OFF \
  -DCMAKE_C_COMPILER=$(which gcc) \
  -DCMAKE_CXX_COMPILER=$(which g++) \
  -DMPI_C_COMPILER=$(which mpicc) \
  -DMPI_CXX_COMPILER=$(which mpicxx) \
  -DCMAKE_C_FLAGS="-O3 -fPIC"
make -j$(nproc)
make install
if [ "X${CMAKE_PREFIX_PATH}X" = "XX" ]
then
  CMAKE_PREFIX=$QMP_HOME
else
  CMAKE_PREFIX=${QMP_HOME}:${CMAKE_PREFIX_PATH}
fi
