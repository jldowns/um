{
  description = "um - create and maintain your own man pages";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
  flake-utils.lib.eachDefaultSystem (system:
  let 
    pkgs = nixpkgs.legacyPackages.${system};
    umRuby = pkgs.ruby_3_0;
    gems = pkgs.bundlerEnv {
      name = "um-gems";
      ruby = umRuby;
      gemfile = ./Gemfile;
      lockfile = ./Gemfile.lock;
      gemset = ./gemset.nix;
      gemdir = ./.;
    };

    # umBuildInputs = [ (pkgs.lib.lowPrio gems) umRuby pkgs.file pkgs.bundix];
    umBuildInputs = [ umRuby gems pkgs.file pkgs.bundix];

  in
  rec {

     # Packages
      packages.um = pkgs.stdenv.mkDerivation {
        name = "um";
        src = ./.;
        nativeBuildInputs = [ pkgs.makeWrapper ];
        buildInputs = umBuildInputs;
         installPhase = ''
           # gem build -o um.gem
           # gem install um.gem
           mkdir -p $out/bin
           cp -r $src/* $out
           wrapProgram "$out/bin/um" \
             --prefix PATH : ${pkgs.lib.strings.makeBinPath [ umRuby ]} \
             --prefix UMCONFIG_HOME : $out
         '';
      };

        defaultPackage = packages.um;

        # Devshell
        devShell = pkgs.mkShell {
          buildInputs = umBuildInputs;
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
            
            environment.systemPackages = [defaultPackage];

            "${defaultPackage.out}/umconfig".text = lib.mkBefore config.programs.um.extraConfig;
            
            };
          }; 
        }
      );
    }


