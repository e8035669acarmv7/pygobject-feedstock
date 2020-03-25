#!/usr/bin/env bash

set -ex

if [ -n "$OSX_ARCH" ] ; then
    export LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"
else
    export LDFLAGS="$LDFLAGS -Wl,-rpath-link,$PREFIX/lib"
fi

meson_config_args=(
  --prefix="$PREFIX"
  --libdir=lib
  --wrap-mode=nofallback
  --buildtype=release
  --backend=ninja
  -D python="$PYTHON"
)

mkdir forgebuild
cd forgebuild
meson setup .. "${meson_config_args[@]}"
ninja -v
# workaround for failing test with pytest 5.4+
# can remove for pygobject versions after (but not including) 3.36
# see https://github.com/GNOME/pygobject/commit/dae0500166068d78150855bdef94f0bee18b31dd
if [[ $target_platform == osx* ]] ; then
    # also skip another test that fails on OSX, upstream bug
    export PYTEST_ADDOPTS="-k 'not test_pytest_capture_error_in_closure and not test_path_exists_various_types'"
else
    export PYTEST_ADDOPTS="-k 'not test_pytest_capture_error_in_closure'"
fi
ninja test
ninja install
