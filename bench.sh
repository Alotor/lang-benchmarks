#!/bin/bash

JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1 -Xmx6g -Xms6g -XX:+UseFastAccessorMethods -XX:+AggressiveOpts" # -XX:+UseG1GC"
JAVA_BIN="/usr/bin/java"
PYTHON2_BIN="/usr/bin/python2.7"
PYTHON3_BIN="/usr/bin/python3.3"
PYPY_BIN="/usr/bin/pypy"
NODE_BIN="/usr/bin/node"
ERLANG_BIN="/usr/bin/erl"
CABAL_BIN="/usr/bin/cabal"
ELIXIR_BIN="/usr/bin/elixir"
RUST_BIN="/usr/bin/rust"

LIST_SIZE=10000
NUMBERS_SIZE=500


echo "Building..."
(cd groovy_bench; gradle build uberjar)
(cd java_bench; gradle build uberjar)
(cd clojure_bench; lein uberjar)
(cd jython_bench; gradle uberjar)
(cd javascript_bench; npm install)

if [ -f $ERLANG_BIN ];
then
    (cd erlang_bench; erl -compile bench)
    (cd erlang_bench; erl -compile bench_parallel)
fi

if [ -f $CABAL_BIN ];
then
    (cd haskell_bench; cabal configure && cabal build)
fi

if [ -f $RUST_BIN ];
then
    (cd rust_bench; $RUST_BIN build bench.rs)
fi

echo "Benchmarking..."
$JAVA_BIN $JAVA_OPTS -jar groovy_bench/build/libs/bench-1.0.jar $LIST_SIZE $NUMBERS_SIZE
$JAVA_BIN $JAVA_OPTS -jar java_bench/build/libs/bench-1.0.jar $LIST_SIZE $NUMBERS_SIZE
$JAVA_BIN $JAVA_OPTS -jar clojure_bench/target/clojure_bench-0.1.0-standalone.jar $LIST_SIZE $NUMBERS_SIZE
$JAVA_BIN $JAVA_OPTS -jar jython_bench/build/libs/bench-1.0.jar $LIST_SIZE $NUMBERS_SIZE
$PYTHON2_BIN python_bench/test.py $LIST_SIZE $NUMBERS_SIZE
$PYTHON3_BIN python_bench/test.py $LIST_SIZE $NUMBERS_SIZE
$PYPY_BIN python_bench/test.py $LIST_SIZE $NUMBERS_SIZE
(cd javascript_bench; $NODE_BIN test.js $LIST_SIZE $NUMBERS_SIZE)

if [ -f $ERLANG_BIN ];
then
    (cd erlang_bench ; erl -noshell -s bench main $LIST_SIZE $NUMBERS_SIZE -s init stop)
    (cd erlang_bench ; erl -noshell -s bench_parallel main $LIST_SIZE $NUMBERS_SIZE -s init stop)
fi

if [ -f $CABAL_BIN ];
then
    (cd haskell_bench; ./dist/build/haskell_bench/haskell_bench $LIST_SIZE $NUMBERS_SIZE)
fi

if [ -f $ELIXIR_BIN ];
then
    (cd elixir_bench; elixir bench.ex $LIST_SIZE $NUMBERS_SIZE)
fi

if [ -f $RUST_BIN ];
then
    ./rust_bench/bench $LIST_SIZE $NUMBERS_SIZE
fi

