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
        packages.um = pkgs.stdenv.mkDerivation {
          name = "um";
          src = ./.;
          buildInputs = [gems pkgs.ruby_3_0];
          installPhase = ''
            mkdir -p $out
            cp -r $src/* $out
          '';
        };

        defaultPackage = packages.um;

        # Devshell
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ gems ruby_3_0 ];
        };

        # Apps
        apps.um = flake-utils.lib.mkApp { drv = packages.um; };
        defaultApp = apps.um;

        # Nixos Module
        nixosModules.um = {config, lib, ...} : {
          # define module options
          options = {
            programs.um = {
              enable = lib.mkEnableOption "Enable um - create and maintain your own man pages.";
            };
          };

          # implementation
          config = lib.mkIf config.programs.um.enable {
            # Enable for NixOS global
            environment.systemPackages = [ defaultPackage ];

            # Enable for Home Manager
            # home.packages = [ defaultPackage ];
          };

        }; 

      }
      );
    }


