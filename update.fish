#!/usr/bin/env fish

# update archived source code

git submodule init
git submodule update
rsync -a mimalloc/LICENSE mimalloc-archive/LICENSE
rsync -a --delete mimalloc/include/ mimalloc-archive/include/
rsync -a --delete mimalloc/src/ mimalloc-archive/src/
