pkgs = [
    // Deprecated

    'openssl', 'postfixDeprecated',
    'php56', 'php55', 'php54', 'php53', 'php52',

    'zendguard', 'zendguard53', 'zendguard54', 'zendguard55', 'zendguard56',

    'php52-dbase', 'php52-imagick', 'php52-intl', 'php52-timezonedb',
    'php52-zendopcache',

    'php53-dbase', 'php53-imagick', 'php53-intl', 'php53-timezonedb',
    'php53-zendopcache',

    'php54-imagick', 'php54-memcached', 'php54-redis', 'php54-timezonedb',
    'php54-zendopcache',

    'php55-dbase', 'php55-imagick', 'php55-intl', 'php55-timezonedb',

    'php56-dbase', 'php56-imagick', 'php56-intl', 'php56-timezonedb',
    'apacheHttpd', 'apacheHttpdmpmITK',

    // Utilities

    'connectorc', 'libjpeg130', 'libpng12', 'elktail', 'clamchk',

    // Perl

    'TextTruncate', 'TimeLocal', 'PerlMagick', 'commonsense', 'Mojolicious',
    'libxml_perl', 'libnet', 'libintl_perl', 'LWP', 'ListMoreUtilsXS',
    'LWPProtocolHttps', 'DBI', 'DBDmysql', 'CGI', 'FilePath', 'DigestPerlMD5',
    'DigestSHA1', 'FileBOM', 'GD', 'LocaleGettext', 'HashDiff', 'JSONXS',
    'POSIXstrftimeCompiler', 'perl', 'nginxModules', 'nginx',
    'openrestyLuajit2', 'pcre831', 'penlight', 'postfix', 'sockexec',
    'zendoptimizer', 'libjpegv6b', 'imagemagick68', 'URIEscape', 'HTMLParser',
    'HTTPDate', 'TryTiny', 'TypesSerialiser', 'XMLLibXML', 'XMLSAX',
    'XMLSAXBase', 'Carp', 'NetHTTP',

    // Postfix

    'sendmail',

    // PHP

    'php70', 'php71', 'php72', 'php73', 'php74',

    'php70-imagick', 'php70-memcached', 'php70-redis', 'php70-rrd',
    'php70-timezonedb',

    'php71-imagick', 'php71-libsodiumPhp', 'php71-memcached', 'php71-redis',
    'php71-rrd', 'php71-timezonedb',

    'php72-imagick', 'php72-memcached', 'php72-redis', 'php72-rrd',
    'php72-timezonedb',

    'php73-imagick', 'php73-memcached', 'php73-redis', 'php73-rrd',
    'php73-timezonedb', 'pure-ftpd',

    'php73Private-imagick', 'php73Private-memcached', 'php73Private-redis',
    'php73Private-rrd', 'php73Private-timezonedb',

    // Misc

    'inetutilsMinimal', 'deepdiff', 'nss-certs.unbundled', 'locale'
]

pipeline {
    agent {
        label 'nixbld'
    }
    stages {
        stage('Build overlay') {
            steps {
                script {
                    sh ([". /home/jenkins/.nix-profile/etc/profile.d/nix.sh",

                         // Show derivations
                         pkgs.collect{
                                ["nix-instantiate", "build.nix",
                                 "--show-trace", "--cores", "16",
                                 "-A overlay.$it", "2>/dev/null"].join(" ")
                            }.join(" && "),

                         // Build specified packages in overlay
                         [["nix-build", "build.nix",
                           "--cores", "16",
                           "--keep-failed", "--show-trace"].join(" "),
                          pkgs.collect{"-A overlay.$it"}.join(" ")].join(" ")

                        ].join(" && "))
                }
            }
        }
    }
    post {
        success { notifySlack "Build ${JOB_NAME} succeeded" , "green" }
        failure { notifySlack "Build failled: ${JOB_NAME} [<${RUN_DISPLAY_URL}|${BUILD_NUMBER}>]", "red" }
    }
}
