{
  description = "zol — a modular text editor (prebuilt Linux x86_64 release)";

  # Only nixpkgs is needed: the package unpacks the public release tarball, so
  # no Zig toolchain or private source access is required. Consumers can pin
  # this to their own nixpkgs with
  #   inputs.zol.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      # Kept in step with each published release: `version` is the release tag
      # (without `v`) and `tarballHash` is the SRI SHA-256 of
      # zol-<version>-linux-x86_64.tar.gz.
      version = "0.4.2";
      tarballHash = "sha256-A4M6W7Hps22MkSrL39HbKiKnRmDCMxWtq6AoP+NN8Og=";

      # Releases are Linux x86_64 only.
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Built against the caller's nixpkgs so an overlay / NixOS module reuses
      # the system's already-evaluated package set.
      mkZol =
        pkgs:
        pkgs.callPackage (
          {
            lib,
            stdenv,
            fetchurl,
            autoPatchelfHook,
            copyDesktopItems,
            makeDesktopItem,
            vulkan-loader,
          }:
          stdenv.mkDerivation {
            pname = "zol";
            inherit version;

            src = fetchurl {
              url = "https://github.com/flyewic/zol-releases/releases/download/v${version}/zol-${version}-linux-x86_64.tar.gz";
              hash = tarballHash;
            };

            # The archive unpacks to a single versioned directory.
            sourceRoot = "zol-${version}-linux-x86_64";

            nativeBuildInputs = [
              autoPatchelfHook
              copyDesktopItems
            ];
            # The binary only NEEDs libc/libm; the Vulkan loader is dlopen'd.
            buildInputs = [ vulkan-loader ];

            # dlopen("libvulkan.so.1") is invisible to autoPatchelfHook, so put
            # the loader on the RPATH explicitly. A working Vulkan driver/ICD
            # still comes from the host (hardware.graphics.enable on NixOS).
            runtimeDependencies = [ vulkan-loader ];

            desktopItems = [
              (makeDesktopItem {
                name = "zol";
                desktopName = "zol";
                genericName = "Text Editor";
                comment = "Modular text editor";
                exec = "zol %F";
                terminal = false;
                startupNotify = true;
                startupWMClass = "zol";
                categories = [
                  "Utility"
                  "TextEditor"
                  "Development"
                ];
                mimeTypes = [
                  "text/plain"
                  "text/x-csrc"
                  "text/x-chdr"
                  "text/x-java"
                  "text/x-python"
                  "text/x-shellscript"
                  "application/json"
                  "application/xml"
                  "inode/directory"
                ];
                keywords = [
                  "text"
                  "editor"
                  "code"
                ];
              })
            ];

            # zol looks these up beside the running binary:
            #   ../lib/zol/languages   grammar packs
            #   ../lib/zol/plugins     bundled (disabled) scripted plugins
            installPhase = ''
              runHook preInstall
              install -Dm755 zol $out/bin/zol

              mkdir -p $out/lib/zol
              cp -a languages $out/lib/zol/languages
              if [ -d plugins ]; then
                cp -a plugins $out/lib/zol/plugins
              fi

              # MIT / Apache / OFL notices must travel with the binary.
              mkdir -p $out/share/doc/zol
              install -m644 LICENSE THIRD_PARTY.md $out/share/doc/zol/
              cp -a LICENSES $out/share/doc/zol/LICENSES
              runHook postInstall
            '';

            meta = {
              description = "A modular text editor built on DVUI with a wio + Vulkan backend";
              longDescription = ''
                zol is a modular text editor written in Zig. This package
                installs the prebuilt Linux x86_64 release binary together
                with its tree-sitter grammar packs and bundled plugins.
              '';
              homepage = "https://github.com/flyewic/zol-releases";
              # Proprietary, all rights reserved; the binary may be run and
              # redistributed unmodified with its notices (LICENSE).
              license = lib.licenses.unfreeRedistributable;
              mainProgram = "zol";
              platforms = [ "x86_64-linux" ];
              sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
            };
          }
        ) { };
    in
    {
      packages = forAllSystems (system: {
        zol = mkZol nixpkgs.legacyPackages.${system};
        default = self.packages.${system}.zol;
      });

      # `nix flake check` builds the package.
      checks = forAllSystems (system: {
        default = self.packages.${system}.default;
      });

      # `programs.zol.enable = true;` in a NixOS configuration.
      nixosModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.programs.zol;
        in
        {
          options.programs.zol = {
            enable = lib.mkEnableOption "zol, a modular text editor";
            package = lib.mkOption {
              type = lib.types.package;
              default = mkZol pkgs;
              defaultText = lib.literalExpression "inputs.zol.packages.${pkgs.stdenv.hostPlatform.system}.default";
              description = "The zol package to install.";
            };
          };

          config = lib.mkIf cfg.enable {
            environment.systemPackages = [ cfg.package ];
          };
        };

      overlays.default = final: _prev: {
        zol = mkZol final;
      };

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/zol";
          meta.description = "Run the zol text editor";
        };
      });

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
