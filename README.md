# zol releases

Public download location for zol, a modular text editor. This repository holds
release binaries, checksums, the installer, and the license/notices — not the
editor's source.

## Install / upgrade

```sh
curl -fsSL https://github.com/flyewic/zol-releases/releases/latest/download/install.sh | sh
```

The installer writes `~/.local/bin/zol`, puts the grammar packs under
`~/.local/lib/zol/languages` and the bundled plugins under
`~/.local/lib/zol/plugins`, and registers a desktop entry. Re-running it
upgrades in place. Make sure `~/.local/bin` is on your `PATH`.

Pin a specific version with `ZOL_VERSION`:

```sh
curl -fsSL https://github.com/flyewic/zol-releases/releases/latest/download/install.sh | ZOL_VERSION=0.1.0 sh
```

A package-managed `zol` is never overwritten; if one is found the installer
stops.

## Nix / NixOS

This repository is also a Nix flake, so it installs from the same release
tarball with no source access and no Zig toolchain. Add it as an input:

```nix
{
  inputs.zol.url = "github:flyewic/zol-releases";

  outputs = { self, nixpkgs, zol, ... }: {
    nixosConfigurations.host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        zol.nixosModules.default
        {
          programs.zol.enable = true;
        }
      ];
    };
  };
}
```

zol's binary is proprietary (all rights reserved, redistributable unmodified),
so nixpkgs treats it as unfree and refuses to install it until you allow it.
Add a predicate for just this package (recommended), or `allowUnfree = true` to
allow every unfree package:

```nix
nixpkgs.config.allowUnfreePredicate = pkg:
  builtins.elem (nixpkgs.lib.getName pkg) [ "zol" ];
```

The `programs.zol` module only adds the package to
`environment.systemPackages`; it does not change your unfree policy, so the
predicate above (or `allowUnfree`) is required either way. Without the module:

```nix
environment.systemPackages = [ inputs.zol.packages.${pkgs.system}.default ];
```

For an ad-hoc run, flakes evaluate nixpkgs themselves, so pass the policy
through the environment:

```sh
NIXPKGS_ALLOW_UNFREE=1 nix run --impure github:flyewic/zol-releases
```

`inputs.zol.overlays.default` exposes `pkgs.zol`. The flake provides
`x86_64-linux` only (matching the release tarball); the Vulkan loader ships with
the package and a working driver/ICD comes from the host
(`hardware.graphics.enable = true;` on NixOS).

## Platforms

Linux `x86_64` is the only supported release target for now. macOS and Windows
builds will be added only if they work well enough to ship.

## Requirements

- Linux `x86_64`, glibc 2.31 or newer
- A Vulkan loader (`libvulkan.so.1`) and a working Vulkan driver

`libc` and `libm` come from your distribution.

## Verifying a download

Each Release publishes a `SHA256SUMS` file next to the tarball. To check a
tarball you fetched by hand:

```sh
sha256sum -c SHA256SUMS
```

## Issues

Report problems or ask questions in this repository's issue tracker:
https://github.com/flyewic/zol-releases/issues

## License

The zol binary is proprietary, all rights reserved; see `LICENSE`. It may be
run and redistributed unmodified with its notices. Third-party components are
listed in `THIRD_PARTY.md`, and the full license texts are under `LICENSES/`.
