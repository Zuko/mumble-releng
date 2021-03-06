#!/bin/bash
SHA1="ec5d20f1ee52ae765b9286e9d7951dcfc9548607"
curl -O http://www.openssl.org/source/openssl-1.0.0k.tar.gz
if [ "$(shasum -a 1 openssl-1.0.0k.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo openssl checksum mismatch
	exit
fi
tar -zxf openssl-1.0.0k.tar.gz

rm -rf openssl-1.0.0k-ppc
cp -R openssl-1.0.0k openssl-1.0.0k-ppc
cd openssl-1.0.0k-ppc
./Configure darwin-ppc-cc no-shared --prefix=$MUMBLE_PREFIX --openssldir=$MUMBLE_PREFIX/openssl
make
make install

cp $MUMBLE_PREFIX/lib/libcrypto.a $MUMBLE_PREFIX/lib/libcrypto-ppc.a
cp $MUMBLE_PREFIX/lib/libssl.a $MUMBLE_PREFIX/lib/libssl-ppc.a
cp $MUMBLE_PREFIX/include/openssl/opensslconf.h $MUMBLE_PREFIX/include/openssl/opensslconf-ppc.h

cd ..
rm -rf openssl-1.0.0k-i386
cp -R openssl-1.0.0k openssl-1.0.0k-i386
cd openssl-1.0.0k-i386
./Configure darwin-i386-cc no-shared --prefix=$MUMBLE_PREFIX --openssldir=$MUMBLE_PREFIX/openssl
make
make install

cp $MUMBLE_PREFIX/lib/libcrypto.a $MUMBLE_PREFIX/lib/libcrypto-i386.a
cp $MUMBLE_PREFIX/lib/libssl.a $MUMBLE_PREFIX/lib/libssl-i386.a
cp $MUMBLE_PREFIX/include/openssl/opensslconf.h $MUMBLE_PREFIX/include/openssl/opensslconf-i386.h

cd $MUMBLE_PREFIX/lib/
lipo -create -arch ppc libcrypto-ppc.a -arch i386 libcrypto-i386.a -output libcrypto.a
lipo -create -arch ppc libssl-ppc.a -arch i386 libssl-i386.a -output libssl.a
rm -rf libcrypto-ppc.a libcrypto-i386.a
rm -rf libssl-ppc.a libssl-i386.a

cd ../include/openssl
printf "// Automatically generated by the Mumble osx-universal build environment.\n" > opensslconf.h
printf "#if defined(i386)\n" >> opensslconf.h
printf "# include \"opensslconf-i386.h\"\n" >> opensslconf.h
printf "#elif defined(__ppc__)\n" >> opensslconf.h
printf "# include \"opensslconf-ppc.h\"\n" >> opensslconf.h
printf "#else\n" >> opensslconf.h
printf "# error Unable to determine target architecture\n" >> opensslconf.h
printf "#endif\n" >> opensslconf.h
