{ stdenv, writeScript }:

stdenv.mkDerivation {
  name = "entrypoint";
  builder = writeScript "builder.sh" (''
    source $stdenv/setup
    mkdir -p $out/bin
    cat > $out/bin/entrypoint <<'EOF'
    ${builtins.readFile ./entrypoint.bash}
    EOF
    chmod 555 $out/bin/entrypoint
  '');
}
