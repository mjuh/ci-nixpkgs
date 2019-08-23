{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "wordpress";
  version = "4.7";

  src = fetchurl {
    url = "https://ru.wordpress.org/${pname}-${version}-ru_RU.tar.gz";
    sha256 = "143m2w5x7axgpn92zbal4v6rd1c50i08gwpdasscrmxzzzk6kv21";
  };

  installPhase = ''
    mkdir -p $out/share/wordpress
    cp -r . $out/share/wordpress
  '';

  meta = with stdenv.lib; {
    homepage = "https://wordpress.org";
    description = "WordPress is open source software you can use to create a beautiful website, blog, or app";
    license = [ licenses.gpl2 ];
    maintainers = [ maintainers.basvandijk ];
    platforms = platforms.all;
  };
}
