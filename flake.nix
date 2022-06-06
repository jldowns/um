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

              enable = lib.mkEnableOption "Enable um configuration. This does not enable the package in environment.systemPackages or home.programs.";

              extraConfig = lib.mkOption {
                type = lib.types.lines;
                description = "Additional configuration.";
                default = "";
              };
            };
          };

          # implementation
          config = lib.mkIf config.programs.um.enable {
            
            xdg.configFile."umconfig".text = lib.mkBefore config.programs.um.extraConfig;

           # home.sessionVariables = {
           #   UMCONFIG_HOME = config.programs.xdg.configHome + "um/um";
           # };
            
            };
          }; 
        }
      );
    }


