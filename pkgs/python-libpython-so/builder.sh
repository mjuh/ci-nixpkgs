set -e
set -x
unset PATH

for p in $buildInputs; do
    export PATH=$p/bin${PATH:+:}$PATH
    export LIB=$p/lib
done

mkdir -p $out/lib
cp $LIB/libpython3.7m.so.1.0 $out/lib
