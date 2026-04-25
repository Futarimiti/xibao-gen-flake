{
  description = "Generate xibao picture";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    xibao-gen = {
      url = "github:onion108/xibao-gen";
      flake = false;
    };
  };

  outputs =
    { flake-parts, xibao-gen, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      perSystem =
        { pkgs, ... }:
        {
          packages.default = pkgs.callPackage ./xibao-gen.nix {
            version = "0.2.0";
            src = xibao-gen;
          };
        };
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    };

  nixConfig = {
    extra-substituters = [ "https://futarimiti.cachix.org" ];
    extra-trusted-public-keys = [
      "futarimiti.cachix.org-1:IGMsvnbRz4LniUy06SNfCVJfLxt6rV3c33//Fb75/2g=c"
    ];
  };
}
