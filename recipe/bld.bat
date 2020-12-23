@ECHO ON


@REM Here we ditch the -GL flag, which messes up symbol resolution.
set "CFLAGS=-MD"
set "CXXFLAGS=-MD"

:: set pkg-config path so that host deps can be found
:: (set as env var so it's used by both meson and during build with g-ir-scanner)
set "PKG_CONFIG_PATH=%LIBRARY_LIB%\pkgconfig;%LIBRARY_PREFIX%\share\pkgconfig;%BUILD_PREFIX%\Library\lib\pkgconfig"

mkdir forgebuild
cd forgebuild

%BUILD_PREFIX%\Scripts\meson --buildtype=release --prefix=%LIBRARY_PREFIX% --backend=ninja -Dpython=%PYTHON% -Dtests=false ..
if errorlevel 1 exit 1

ninja -v
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1

@REM Meson doesn't put the Python files in the right place.
cd %LIBRARY_PREFIX%\lib\python*
cd site-packages
move *.egg-info %PREFIX%\lib\site-packages
move gi %PREFIX%\lib\site-packages\gi
move pygtkcompat %PREFIX%\lib\site-packages\gi
