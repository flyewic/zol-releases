# Third-party notices

zol is distributed as a self-contained Linux `x86_64` binary. This file lists
every third-party work linked into or embedded in that binary, with its
copyright and license. It is included in every release tarball, as required by
the licenses below. zol's own terms are in `LICENSE`.

Nothing here grants rights in the zol source, which is not published.

This inventory was last walked on 2026-09-25 against `build.zig.zon` and
`vendor/` at version 0.1.0.

## Linked runtime components

| Component | Copyright | License | Upstream |
|---|---|---|---|
| DVUI | © David Vanderson and contributors | MIT | https://github.com/david-vanderson/dvui (fork: https://github.com/flyewic/dvui-zol) |
| TinyVG (decoder, via DVUI `tvg`) | © TinyVG contributors | MIT | https://github.com/ikskuh/TinyVG |
| zig-lib-svg2tvg | © nat3Github contributors | MIT | https://github.com/nat3Github/zig-lib-svg2tvg |
| wio | © Elaine Gibson and contributors | MIT | https://github.com/sourgrasses/wio (fork: https://github.com/flyewic/wio-zol) |
| Ghostty / libghostty-vt | © 2024 Mitchell Hashimoto, Ghostty contributors | MIT | https://github.com/ghostty-org/ghostty |
| tree-sitter runtime | © 2018 Max Brunsfeld, tree-sitter contributors | MIT | https://github.com/tree-sitter/tree-sitter |
| zig-tree-sitter (bindings) | © 2024 tree-sitter contributors | MIT | https://github.com/tree-sitter/zig-tree-sitter |
| tree-sitter-zig grammar | © 2024 Amaan Qureshi | MIT | https://github.com/david-vanderson/tree-sitter-zig |
| KDL parser for Zig (`kdl-zol` fork) | © 2025 Colin Jones | MIT | https://github.com/flyewic/kdl-zig-zol |
| QuickJS | © 2017–2021 Fabrice Bellard, Charlie Gordon | MIT | https://bellard.org/quickjs/ |
| FreeType | © 1996–2024 David Turner, Robert Wilhelm, Werner Lemberg | FreeType License (FTL) | https://freetype.org |
| stb_image | © 2017 Sean Barrett and contributors | public domain / MIT (dual) | https://github.com/nothings/stb |
| vulkan-zig (generated bindings) | © Robin Voetter | MIT | https://github.com/Snektron/vulkan-zig |
| Vulkan-Headers | © 2015–2024 The Khronos Group Inc. | Apache-2.0 | https://github.com/KhronosGroup/Vulkan-Headers |
| JetBrains Mono (typeface) | © 2020 JetBrains s.r.o. | SIL Open Font License 1.1 | https://www.jetbrains.com/lp/mono/ |
| Nerd Fonts glyphs | © 2014 Ryan L McIntyre | MIT | https://github.com/ryanoasis/nerd-fonts |

The embedded fonts are subsets; see `src/ui/fonts/LICENSE` for the exact
license texts and the subsetting command. The app icon in `assets/` is
original zol artwork.

FreeType is dual-licensed under the FTL and GPLv2. zol uses it under the
**FTL**; the GPL option is not taken. Vulkan is loaded at runtime with
`dlopen` and is not linked or shipped.

## Vendored tree-sitter grammars

Each grammar under `vendor/tree_sitter/<id>/` is a copy of generated C sources
from the upstream repository below. The editor never links these into the
executable: they are built as `grammar.so` packs under `languages/<id>/` and
loaded at runtime. The highlight queries under `src/syntax/queries/` are
derived from the respective upstream repository; Kotlin's is derived from
nvim-treesitter (© nvim-treesitter contributors, Apache-2.0), as noted in that
file.

| id | Upstream | License |
|---|---|---|
| bash | tree-sitter/tree-sitter-bash | MIT |
| c | tree-sitter/tree-sitter-c | MIT |
| cpp | tree-sitter/tree-sitter-cpp | MIT |
| csharp | tree-sitter/tree-sitter-c-sharp | MIT |
| css | tree-sitter/tree-sitter-css | MIT |
| glsl | tree-sitter-grammars/tree-sitter-glsl | MIT |
| go | tree-sitter/tree-sitter-go | MIT |
| haxe | tong/tree-sitter-haxe | MIT |
| html | tree-sitter/tree-sitter-html | MIT |
| java | tree-sitter/tree-sitter-java | MIT |
| javascript | tree-sitter/tree-sitter-javascript | MIT |
| json | tree-sitter/tree-sitter-json | MIT |
| just | casey/tree-sitter-just | Apache-2.0 |
| kdl | tree-sitter-grammars/tree-sitter-kdl | MIT |
| kotlin | fwcd/tree-sitter-kotlin | MIT |
| lua | tree-sitter-grammars/tree-sitter-lua | MIT |
| markdown | tree-sitter-grammars/tree-sitter-markdown | MIT |
| nim | alaviss/tree-sitter-nim | MPL-2.0 |
| odin | tree-sitter-grammars/tree-sitter-odin | MIT |
| php | tree-sitter/tree-sitter-php | MIT |
| python | tree-sitter/tree-sitter-python | MIT |
| ruby | tree-sitter/tree-sitter-ruby | MIT |
| rust | tree-sitter/tree-sitter-rust | MIT |
| toml | tree-sitter-grammars/tree-sitter-toml | MIT |
| typescript | tree-sitter/tree-sitter-typescript | MIT |
| typst | uben0/tree-sitter-typst | MIT |
| umka | thacuber2a03/tree-sitter-umka | MIT |
| wren | jossephus/tree-sitter-wren | MIT |
| yaml | tree-sitter-grammars/tree-sitter-yaml | MIT |

`html`, `css`, and `typst` ship their upstream `LICENSE` files inside the
vendored directory. The others carry no license file in the generated sources;
the license is the upstream repository's, as recorded above.

Notes on the two non-MIT grammars:

- **just** is Apache-2.0. The vendored `scanner.c` is an unmodified upstream
  copy; the upstream project has no `NOTICE` file to reproduce.
- **nim** is MPL-2.0, a file-level copyleft. The vendored sources are
  unmodified, and the covered source is available at the upstream URL above
  under MPL-2.0. MPL-2.0 permits distribution of these files as part of a
  larger proprietary work.

## Build-time and optional components (not in the binary)

zol builds against the `wio` + Vulkan backend only. DVUI's other backends and
tooling pull additional permissively-licensed packages into the build cache
(SDL3, raylib, pugl, OpenGL, zgl, zglfw, win32, AccessKit BSD-3-Clause, the
Emscripten SDK, system SDKs, and icon/color-scheme test assets). These are
build-time only in this configuration and are not linked into or shipped with
the zol binary. Any future change that enables one must add it to the linked
table above.

## Inventory gate

Every entry in `build.zig.zon` and `vendor/` was walked. No GPL- or
LGPL-licensed work is linked into the distributed binary. FreeType is used
under the FTL, not its GPL option. The only copyleft item is the MPL-2.0 nim
grammar (file-level, not GPL), which satisfies the notice/source requirements
above. This clears the P0 blocker in `docs/releases.md` §4.3.
