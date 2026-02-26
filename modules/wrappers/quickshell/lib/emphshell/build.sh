#!/bin/bash

BUILD_DIRECTORY=./build
CACHE_DIRECTORY=./.cache

if [ "$1" == "help" ]; then
    echo "Usage: ./build.sh [clean|install]"
else
    if [ -d "$BUILD_DIRECTORY" ] || [ "$1" == "clean" ]; then
        sudo rm -r "$BUILD_DIRECTORY" "$CACHE_DIRECTORY"
    fi

    if [ "$1" == "install" ]; then
        cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/
        cmake --build build
        sudo cmake --install build

    else
        cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B build
    fi
fi
