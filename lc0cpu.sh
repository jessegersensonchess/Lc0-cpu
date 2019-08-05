#!/bin/bash

/root/lc0/build/release/./lc0 --weights=/root/LD2.pb.gz --minibatch-size=4 --max-prefetch=0 --threads=45 --backend-opts=blas_cores=1 --syzygy-paths=/data/tmptablebases