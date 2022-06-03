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
        # inherit ruby;
        gemdir = ./.;
      };

  in
  rec {

        # Packages
        packages.defaultPackage.${system} = pkgs.stdenv.mkDerivation {
          name = "um";
          src = ./.;
          buildInputs = [gems pkgs.ruby_3_0];
          installPhase = ''
            mkdir -p $out
            cp -r $src $out
          '';
        };

        # Devshell
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ gems ruby_3_0 ];
        };

        # Apps
        apps.um = flake-utils.lib.mkApp { drv = packages.defaultPackage.${system}; };
        defaultApp = apps.um;
      }
      );
    }


