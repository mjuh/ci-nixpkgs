{ gnused, redis }:

redis.overrideAttrs (old: rec {
  buildInputs = [ gnused ];
  preInstall = ''
    sed -i '/$(REDIS_INSTALL) $(REDIS_SERVER_NAME) $(INSTALL_BIN)/d' src/Makefile
    sed -i '/$(REDIS_INSTALL) $(REDIS_BENCHMARK_NAME) $(INSTALL_BIN)/d' src/Makefile
    sed -i '/$(REDIS_INSTALL) $(REDIS_CHECK_RDB_NAME) $(INSTALL_BIN)/d' src/Makefile
    sed -i '/$(REDIS_INSTALL) $(REDIS_CHECK_AOF_NAME) $(INSTALL_BIN)/d' src/Makefile
    sed -i '/@ln -sf $(REDIS_SERVER_NAME) $(INSTALL_BIN)\/$(REDIS_SENTINEL_NAME)/d' src/Makefile
  '';
})
