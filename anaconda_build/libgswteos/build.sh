make
mkdir -p $PREFIX/lib $PREFIX/include
install libgswteos-10.so.3.0 $PREFIX/lib
install gswteos-10.h $PREFIX/include
ln -sf $PREFIX/lib/libgswteos-10.so.3.0 $PREFIX/lib/libgswteos-10.so
