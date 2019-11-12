pipeline {
    agent { label 'nixbld' }
    stages {
        stage('Build overlay') {
            steps {
                //  -A overlay.luajitPackages
                sh '. /home/jenkins/.nix-profile/etc/profile.d/nix.sh && ' +
                'nix-build build.nix --cores 16 --keep-failed --show-trace ' +
                '-A overlay.openssl ' +
                '-A overlay.postfixDeprecated ' +

                '-A overlay.php56 ' +
                '-A overlay.php55 ' +
                '-A overlay.php54 ' +
                '-A overlay.php53 ' +
                '-A overlay.php52 ' +

                '-A overlay.zendguard ' +
                '-A overlay.zendguard53 ' +
                '-A overlay.zendguard54 ' +
                '-A overlay.zendguard55 ' +
                '-A overlay.zendguard56 ' +

                '-A overlay.php52-dbase ' +
                '-A overlay.php52-imagick ' +
                '-A overlay.php52-intl ' +
                '-A overlay.php52-timezonedb ' +
                '-A overlay.php52-zendopcache ' +

                '-A overlay.php53-dbase ' +
                '-A overlay.php53-imagick ' +
                '-A overlay.php53-intl ' +
                '-A overlay.php53-timezonedb ' +
                '-A overlay.php53-zendopcache ' +

                '-A overlay.php54-imagick ' +
                '-A overlay.php54-memcached ' +
                '-A overlay.php54-redis ' +
                '-A overlay.php54-timezonedb ' +
                '-A overlay.php54-zendopcache ' +

                '-A overlay.php55-dbase ' +
                '-A overlay.php55-imagick ' +
                '-A overlay.php55-intl ' +
                '-A overlay.php55-timezonedb ' +

                '-A overlay.php56-dbase ' +
                '-A overlay.php56-imagick ' +
                '-A overlay.php56-intl ' +
                '-A overlay.php56-timezonedb ' +
                '-A overlay.apacheHttpd ' +
                '-A overlay.apacheHttpdmpmITK ' +

                '-A overlay.connectorc ' +
                // '-A overlay.ioncube ' +
                '-A overlay.libjpeg130 ' +
                '-A overlay.libpng12 ' +
                '-A overlay.elktail ' +
                '-A overlay.clamchk ' +
                // '-A overlay.mjHttpErrorPages ' +
                // '-A overlay.mjperl5Packages ' +
                // '-A overlay.mjperl5lib ' +
                // '-A overlay.mjPerlPackages ' +
                '-A overlay.TextTruncate ' +
                '-A overlay.TimeLocal ' +
                '-A overlay.PerlMagick ' +
                '-A overlay.commonsense ' +
                '-A overlay.Mojolicious ' +
                '-A overlay.libxml_perl ' +
                '-A overlay.libnet ' +
                '-A overlay.libintl_perl ' +
                '-A overlay.LWP ' +
                '-A overlay.ListMoreUtilsXS ' +
                '-A overlay.LWPProtocolHttps ' +
                '-A overlay.DBI ' +
                '-A overlay.DBDmysql ' +
                '-A overlay.CGI ' +
                '-A overlay.FilePath ' +
                '-A overlay.DigestPerlMD5 ' +
                '-A overlay.DigestSHA1 ' +
                '-A overlay.FileBOM ' +
                '-A overlay.GD ' +
                '-A overlay.LocaleGettext ' +
                '-A overlay.HashDiff ' +
                '-A overlay.JSONXS ' +
                '-A overlay.POSIXstrftimeCompiler ' +
                '-A overlay.perl ' +
                '-A overlay.nginxModules ' +
                '-A overlay.nginx ' +
                '-A overlay.openrestyLuajit2 ' +
                '-A overlay.pcre831 ' +
                '-A overlay.penlight ' +
                '-A overlay.postfix ' +
                '-A overlay.sockexec ' +
                '-A overlay.zendoptimizer ' +
                '-A overlay.libjpegv6b ' +
                '-A overlay.imagemagick68 ' +
                '-A overlay.URIEscape ' +
                '-A overlay.HTMLParser ' +
                '-A overlay.HTTPDate ' +
                '-A overlay.TryTiny ' +
                '-A overlay.TypesSerialiser' +

                '-A overlay.php70 ' +
                '-A overlay.php71 ' +
                '-A overlay.php72 ' +
                '-A overlay.php73 ' +

                // TODO:
                // '-A overlay.php73zts ' +
                // '-A overlay.php73ztsFpm ' +

                '-A overlay.php70-imagick ' +
                '-A overlay.php70-memcached ' +
                '-A overlay.php70-redis ' +
                '-A overlay.php70-rrd ' +
                '-A overlay.php70-timezonedb ' +

                '-A overlay.php71-imagick ' +
                '-A overlay.php71-libsodiumPhp ' +
                '-A overlay.php71-memcached ' +
                '-A overlay.php71-redis ' +
                '-A overlay.php71-rrd ' +
                '-A overlay.php71-timezonedb ' +

                '-A overlay.php72-imagick ' +
                '-A overlay.php72-memcached ' +
                '-A overlay.php72-redis ' +
                '-A overlay.php72-rrd ' +
                '-A overlay.php72-timezonedb ' +

                '-A overlay.php73-imagick ' +
                '-A overlay.php73-memcached ' +
                '-A overlay.php73-redis ' +
                '-A overlay.php73-rrd ' +
                '-A overlay.php73-timezonedb ' +
                '-A overlay.pure-ftpd ' +
                '-A overlay.mcron ' +

                '-A overlay.php73Private-imagick ' +
                '-A overlay.php73Private-memcached ' +
                '-A overlay.php73Private-redis ' +
                '-A overlay.php73Private-rrd ' +
                '-A overlay.php73Private-timezonedb ' +

                '-A overlay.inetutilsMinimal ' +

                '-A overlay.deepdiff ' +

                '-A overlay.nss-certs.unbundled'

            }
        }
    }
    post {
        success { notifySlack "Build ${JOB_NAME} succeeded" , "green" }
        failure { notifySlack "Build failled: ${JOB_NAME} [<${RUN_DISPLAY_URL}|${BUILD_NUMBER}>]", "red" }
    }
}
