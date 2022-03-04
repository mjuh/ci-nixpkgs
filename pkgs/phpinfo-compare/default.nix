{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "phpinfo-compare";
  version = "0.1-1.0vy9kgjh";
  src = fetchFromGitHub {
    owner = "brettalton";
    repo = "phpinfo-compare";
    rev = "8104201ba5302cc48c38c1dbb6541b9fd69f8aef";
    sha256 = "1p8jg4dm0rkcggcrh5bsh983hls7q3xnwxqag3ic2sdhrcj5dyal";
  };
  configurePhase = false;
  dontBuild = true;
  installPhase   = ''
    substituteInPlace compare.php \
      --replace "'http://example.com/phpinfo.php'" '$argv[1]' \
      --replace "'http://example.com/phpinfo-2.php'" '$argv[2]'

    install -D compare.php "$out/bin/compare"
  '';
}

