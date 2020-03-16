{ pkgs ? import <nixpkgs> { }, url }:

with pkgs;

writeScript "wrk.sh" ''
  #!${bash}/bin/bash
  # Run wrk test.
  exec &> /tmp/xchg/coverage-data/wrk.html
  cat <<EOF
  <html>
    <head>
  <title>wrk</title>
  </head>
  <body>
  <h1>wrk</h1>
  <pre>
  <code>
  EOF
  ${wrk2}/bin/wrk2 -t2 -c100 -d30s -R2000 ${url}
  cat <<EOF
  </code>
  </pre>
  </body>
  </html>
  EOF
''
