{ sources ? import ./nix/sources.nix, pkgs ? import <nixpkgs> { } }:

with pkgs;
let inherit (lib) optional optionals;

in mkShell {
  buildInputs = [ (import ./nix/default.nix { inherit pkgs; }) niv ]
    ++ optional stdenv.isLinux inotify-tools
    ++ optional stdenv.isDarwin terminal-notifier ++ optionals stdenv.isDarwin
    (with darwin.apple_sdk.frameworks; [ CoreFoundation CoreServices ]);

  LOCALE_ARCHIVE_2_27 = "${glibcLocales}/lib/locale/locale-archive";

  shellHook = ''
    export LANG="en_US.UTF-8"

    export PGDATABASE=github_webhook
    export PGUSERNAME=postgres
    export PGPASSWORD=postgres
    export PGHOSTNAME=localhost
    export PGPORT=5433

    export PGDATA=$PWD/db
    export PGHOST=$PWD/postgres
    export PGDATABASE=github_webhook
    export LOG_PATH=$PWD/postgres/LOG

    export DATABASE_URL="postgresql:///$PGUSERNAME:$PGPASSWORD@localhost:$PGPORT/$PGDATABASE"

    if [ ! -d $PGHOST ]; then
      mkdir -p $PGHOST
    fi

    if [ ! -d $PGDATA ]; then
      initdb --auth=trust --no-locale --encoding=UTF8
    fi

    postgres_start() {
      if ! pg_ctl status
      then
        pg_ctl start -l $LOG_PATH -o "-c unix_socket_directories='$PGHOST'"
      fi
    }

  postgres_setup() {
      postgres_start
      createdb $PGDATABASE
      psql -c "CREATE ROLE $PGUSERNAME WITH LOGIN SUPERUSER PASSWORD '$PGPASSWORD';"
    }
  '';
}
