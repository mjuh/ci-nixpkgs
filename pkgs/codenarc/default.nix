{ stdenv, fetchurl, openjdk, writeScript, bash, jq }:

let
  groovy = fetchurl {
    url = "https://repo1.maven.org/maven2/org/codehaus/groovy/groovy-all/2.4.15/groovy-all-2.4.15.jar";
    sha256 = "1w2siawsbap3aqvp06jynw7ki79majc4k2ci4ds5ds422zkw9mji";
  };
  slf4j = fetchurl {
    url = "https://repo1.maven.org/maven2/org/slf4j/slf4j-api/1.7.25/slf4j-api-1.7.25.jar";
    sha256 = "0yavwayiv5pkbzvlvmqaaqpxsa9xn9xpcbjr2ywac7awbl4s1i0q";
  };
in stdenv.mkDerivation rec {
  pname = "codenarc";
  version = "2.1.0";
  src = fetchurl {
    url = "https://github.com/CodeNarc/CodeNarc/releases/download/v${version}/CodeNarc-${version}.jar";
    sha256 = "060fcda2ww1djk7rpsgf4vdzwa3rr3ajcxb8846lxa1cqnppwk06";
  };
  dontUnpack = true;
  wrapper = writeScript "codenarc" ''
    #!${bash}/bin/bash
    CLASSPATH=${src}:${slf4j}:${groovy} exec -a "$0" ${openjdk}/bin/java org.codenarc.CodeNarc "$@"
  '';

  checkInputs = [ jq ];
  checkPhase = ''
    cp ${./test.groovy} test.groovy
    [[ $(${wrapper} -report=json:stdout | jq --raw-output '.summary.filesWithViolations') -eq 1 ]]
  '';
  doCheck = true;

  installPhase = ''
    mkdir -p $out/bin
    install $wrapper $out/bin/codenarc
  '';
}
