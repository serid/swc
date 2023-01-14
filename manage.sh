function setup() {
    git submodule update --init --recursive
    
    #nix-env --install --remove-all --attr nixos.rustup ...
    nix-env --install --attr nixos.rustup nixos.nodejs nixos.deno nixos.gcc \
        nixos.gnumake nixos.pkg-config \
        nixos.openssl
    rustup target add wasm32-wasi

    # Nix does not allow installs into global store
    #npm install --global yarn
    
    if [[ -z "$YARN_GOES_HERE" ]]; then
        export YARN_GOES_HERE=`mktemp -d`
    fi
    npm install yarn --prefix $YARN_GOES_HERE
    export PATH=$PATH:`readlink -f $YARN_GOES_HERE/node_modules/yarn/bin/`
    yarn

    # OPENSSL_DIR assumes that lib/ and include/ are in one derivation, but that is not the
    # case on Nix
    # export OPENSSL_DIR=/nix/store/v3rxj6j9wnwhnfaa7fqb22qacrb86nxn-openssl-3.0.7-dev/
    
    # Use pkg-config
    export PKG_CONFIG_PATH=/nix/store/v3rxj6j9wnwhnfaa7fqb22qacrb86nxn-openssl-3.0.7-dev/lib/pkgconfig/
    cargo build --no-default-features --features swc_v1 --features filesystem_cache
    unset PKG_CONFIG_PATH
}

function cleanup_global() {
    rustup toolchain remove nightly-2022-09-23-x86_64-unknown-linux-gnu
    #rustup target remove wasm32-wasi
}

function cleanup_local() {
    rm -rf target
    rm -rf ./node_modules
    rm -rf $YARN_GOES_HERE
    nix-env -e '.*'
}

function test() {
    export RUST_BACKTRACE=full
    export PATH="$PATH:$PWD/node_modules/.bin"
    export RUST_MIN_STACK=16777216
    #cargo test --all --no-default-features --features swc_v1 --features filesystem_cache
    cargo test -p swc_ecma_transforms --all-features
}

case $1 in
"")
    echo expected a subcommand
    ;;
setup)
    setup
    ;;
test)
    test
    ;;
cleanup)
    cleanup_global
    cleanup_local
    ;;
*)
    echo unrecognized subcommand
    ;;
esac