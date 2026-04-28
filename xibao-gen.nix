{
  lib,
  rustPlatform,
  stdenv,
  linkFarm,
  fetchFromGitHub,
  fetchgit,
  runCommand,
  removeReferencesTo,

  pkg-config,
  python3,
  ninja,
  sdl3,
  sdl3-image,
  cctools,
  clangStdenv,
  gn,
  fontconfig,

  pname ? "xibao-gen",
  src,
  version ? "unstable-${src.lastModifiedDate}",
}:
rustPlatform.buildRustPackage.override { stdenv = clangStdenv; } (finalAttrs: {
  inherit pname version src;

  cargoHash = "sha256-yzCTVfu1tyBOTRN1XYqVFyfxnoGwa2/D3c73ib/jrkI=";

  env = {
    SKIA_SOURCE_DIR =
      let
        repo = fetchFromGitHub {
          owner = "rust-skia";
          repo = "skia";
          tag = "m141-0.88.0";
          hash = "sha256-CB7zRtAQ2KNak6YZB+5kAN/nkmou+mJM/pK/skN9Fqk=";
        };
        externals = linkFarm "skia-externals" (
          lib.mapAttrsToList (name: value: {
            inherit name;
            path = fetchgit value;
          }) (lib.importJSON ./skia-externals.json)
        );
      in
      runCommand "source" { } ''
        cp -R ${repo} $out
        chmod -R +w $out
        ln -s ${externals} $out/third_party/externals
      '';
    SKIA_GN_COMMAND = lib.getExe gn;
    SKIA_NINJA_COMMAND = lib.getExe ninja;
  };

  buildInputs = [
    sdl3
    sdl3-image
    rustPlatform.bindgenHook
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux fontconfig;

  nativeBuildInputs = [
    pkg-config
    python3 # skia
    removeReferencesTo
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin cctools.libtool;

  postFixup = ''
    remove-references-to -t "$SKIA_SOURCE_DIR" $out/bin/xibao-gen
  '';

  postInstall = ''
    install -Dm644 -t "$out/share/xibao-gen" resource/*
  '';

  disallowedReferences = [ finalAttrs.env.SKIA_SOURCE_DIR ];

  dontConfigure = true;

  meta = {
    description = "Generate xibao picture";
    homepage = "https://github.com/onion108/xibao-gen";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "xibao-gen";
    platforms = lib.platforms.all;
  };
})
