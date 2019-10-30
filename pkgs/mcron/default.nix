{ fetchurl, stdenv, guile, which, ed, libtool, pkg-config }:

stdenv.mkDerivation rec {
  name = "mcron-1.1.1";

  src = fetchurl {
    url = "mirror://gnu/mcron/${name}.tar.gz";
    sha256 = "1i9mcp6r6my61zfiydsm3n6my41mwvl7dfala4q29qx0zn1ynlm4";
  };

  configureFlags = ["--disable-multi-user"];

  patches = [ ./0001-base-Display-job-to-STDOUT.patch
              ./0002-scripts-cron-Don-t-daemonize.patch
              ./0003-mcron-vixie-specification-Don-t-send-emails.patch
              ./0005-mcron-fix-exec.patch
              ./0006-mcron-crontab.patch ];

  buildInputs = [ guile which ed libtool pkg-config ];

  doCheck = false;

  postInstall = "install bin/cron $out/bin; install bin/crontab $out/bin";

  meta = {
    description = "Flexible implementation of `cron' in Guile";

    longDescription = ''
      The GNU package mcron (Mellor's cron) is a 100% compatible
      replacement for Vixie cron.  It is written in pure Guile, and
      allows configuration files to be written in scheme (as well as
      Vixie's original format) for infinite flexibility in specifying
      when jobs should be run.  Mcron was written by Dale Mellor.
    '';

    homepage = https://www.gnu.org/software/mcron/;

    license = stdenv.lib.licenses.gpl3Plus;
    platforms = stdenv.lib.platforms.unix;
  };
}
