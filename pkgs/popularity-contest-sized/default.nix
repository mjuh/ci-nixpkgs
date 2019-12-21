{ runCommand, python3, coreutils, writeTextFile }:
exclude: minSize: path:
let
  excludePath = if builtins.isList exclude
    then
      builtins.concatStringsSep ":" exclude
    else
      builtins.toString exclude;
in
runCommand "closure-paths"
{
  exportReferencesGraph.graph = path;
  __structuredAttrs = true;
  PATH = "${coreutils}/bin:${python3}/bin";
  builder = writeTextFile {
    name = "builder";
    text =  ''
      . .attrs.sh
      python3 ${./closure-graph.py} .attrs.json graph ${builtins.toString minSize} ${path} ${excludePath} > ''${outputs[out]}
    '';
  };
}
""
