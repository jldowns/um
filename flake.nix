{
  description = "um - create and maintain your own man pages";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  outputs = { self, nixpkgs, flake-utils}:
    flake-utils.lib.eachDefaultSystem (system:
    let 
      pkgs = nixpkgs.legacyPackages.${system};
      gems = pkgs.bundlerEnv {
        name = "um-gems";
        #inherit ruby;
        gemdir = ./.;
      };

    in
      rec {

        # Packages
        packages = flake-utils.lib.flattenTree {
          hello = pkgs.hello;
          gitAndTools = pkgs.gitAndTools;
        };
        defaultPackage = packages.hello;

        # Devshell
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            gems
          ];
          };

        # Apps
        apps.hello = flake-utils.lib.mkApp { drv = packages.hello; };
        defaultApp = apps.hello;
      }
    );
}


