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
              globalEnable = lib.mkEnableOption "Enable um as a global NixOS Module.";
            };
            programs.um = {
              hmEnable = lib.mkEnableOption "Enable um as a global NixOS Module.";
            };
          };

          # implementation
          config = {
            lib.mkIf config.programs.um.globalEnable {
              # Enable for NixOS global
              environment.systemPackages = [ defaultPackage ];
            };
            lib.mkIf config.programs.um.hmEnable {
              # Enable for Home Manager
              home.packages = [ defaultPackage ];
            };
          };
        }; 
      }
      );
    }


