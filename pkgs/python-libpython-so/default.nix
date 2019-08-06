{ stdenv, bash, coreutils, python37 }:

derivation {
  unpackPhase = "true";
  src = "";
  name = "python-libpython-so";
  builder = "${bash}/bin/bash";
  buildInputs = [ coreutils python37 ];
  args = [ ./builder.sh ];
  system = builtins.currentSystem;
}
