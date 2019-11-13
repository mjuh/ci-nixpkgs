{ stdenv, glibcLocales, lib }:

with lib;

(glibcLocales.override {
  allLocales = false;
  locales = [
    "en_US.UTF-8/UTF-8"
    "ru_UA.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8"
    "ru_RU.KOI8-R/KOI8-R"
    "ru_RU.CP1251/CP1251"
  ];
}).overrideDerivation
  (old: rec {
    preBuildPhases = ["preBuildPhase"];
    preBuildPhase = ''
        echo 'ru_RU.CP1251/CP1251 \' >> ../glibc-2*/localedata/SUPPORTED
      '';
  })
