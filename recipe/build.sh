#!/bin/bash

set -exo pipefail

if [[ "$build_platform" != "$target_platform" ]]; then
    EXTRA_CMAKE_ARGS="-D_CXX_ATOMIC_BUILTIN_EXITCODE=0"
fi

if [[ "$target_platform" == "osx-"* ]]; then
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# Refer to https://github.com/conda-forge/dssp-feedstock/pull/14#issuecomment-2974049079 for `-DCIFPP_DATA_DIR=''`
cmake -S . -B build \
    ${CMAKE_ARGS} \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_CXX_STANDARD=20 \
    -DBUILD_TESTING=OFF \
    -DINSTALL_LIBRARY=ON \
    -DBUILD_PYTHON_MODULE=ON \
    -DPython_ROOT_DIR="${PREFIX}" \
    -DCIFPP_DOWNLOAD_CCD=ON \
    -DCIFPP_INSTALL_UPDATE_SCRIPT=OFF \
    -DCIFPP_DATA_DIR='' \
    -DCIFPP_SHARE_DIR="${PREFIX}/share/libcifpp" \
    ${EXTRA_CMAKE_ARGS}
cmake --build build --config Release --parallel "${CPU_COUNT}"
cmake --install build
cp -f "${SRC_DIR}/build/_deps/cifpp-src/rsrc/"* "${PREFIX}/share/libcifpp/"

# activaton and deactivation scripts
mkdir -p "${PREFIX}/etc/conda/activate.d"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
install -m 644 "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/dssp_activate.sh"
install -m 644 "${RECIPE_DIR}/deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/dssp_deactivate.sh"
install -m 644 "${RECIPE_DIR}/activate.fish" "${PREFIX}/etc/conda/activate.d/dssp_activate.fish"
install -m 644 "${RECIPE_DIR}/deactivate.fish" "${PREFIX}/etc/conda/deactivate.d/dssp_deactivate.fish"
