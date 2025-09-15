#!/usr/bin/env bash

set -euo pipefail

mkdir -p build
pushd build

wget https://github.com/torvalds/linux/archive/refs/tags/v6.16.tar.gz
mkdir linux && tar xvf v6.16.tar.gz -C linux --strip-components 1
pushd linux
make tinyconfig
popd

wget https://www.lua.org/ftp/lua-5.4.8.tar.gz
tar xvf lua-5.4.8.tar.gz
pushd lua-5.4.8
pushd src
make
popd
popd

gcc -c -Os -fno-ident -fno-asynchronous-unwind-tables -fno-stack-protector -fomit-frame-pointer -o shell.o ../src/shell.c
as ../src/sys.S -o sys.o

mkdir -p bin
ld shell.o sys.o -o ./bin/init -T ../src/custom.ld --strip-all -z noexecstack
pushd bin
echo init | cpio -H newc -o > init.cpio
popd
popd
