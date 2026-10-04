# AERO SMP TWO

Modpack for the aeronautics SMP: Create, Create Aeronautics, Sable physics, CC: Tweaked and a long tail of addons.

| | |
|---|---|
| Minecraft | 1.21.1 |
| Loader | NeoForge 21.1.252 |
| Format | Modrinth pack (`.mrpack`) |
| Built in | Prism Launcher |

## How this repo works

The pack is designed and tested in Prism Launcher. This repo holds the unzipped contents of each Prism export, so git can show exactly what changed between versions.

```
modrinth.index.json   list of mods, resource packs and shaders fetched from the Modrinth CDN
overrides/
  config/             mod configs
  kubejs/             recipe and script changes
  mods/               jars bundled directly (not available from Modrinth under that exact version)
  resourcepacks/
  shaderpacks/
```

Most mods are listed in `modrinth.index.json` and downloaded by URL. Anything that could not be matched to a Modrinth file is bundled as a jar in `overrides/mods/`. Overrides are copied into the instance as-is, so they replace any local file with the same name.

## Installing (players)

The pack is published on Modrinth: <!-- add the project link here -->

- **Modrinth App:** open the pack's page and press Install.
- **Prism Launcher:** Add Instance, then the Modrinth tab, and search for the pack. Updates show up in Prism when a new version is published.

Fallback: download the `.mrpack` from this repo's Releases page and use Add Instance, Import in Prism (a direct URL works too).

## Installing (server)

Use the server host's Modrinth modpack installer and pick this pack. If your host has no such option, a tool like `mrpack-install` resolves the index and downloads the mods; check its documentation for current usage.

Known issue: a few client-only jars are still bundled in `overrides/mods/` and will end up on the server. Remove them from the server's `mods` folder after installing:

- `voxy`
- `dlss-style`
- `ToastControl`
- `gpumemleakfix`
- `clientcrafting`
- `flashback_aero`

This list is a starting point, not exhaustive. Shaders and resource packs are optional on the server and can be deleted.

## Updating the pack (maintainers)

1. Make your changes in the Prism instance and test them.
2. In Prism, export the instance as a Modrinth pack.
3. In this repo, wipe the old contents and unzip the new export, so deleted files do not linger:

   ```bash
   rm -rf overrides modrinth.index.json
   unzip -q AERO_SMP_TWO_X.mrpack
   git add -A
   git commit -m "Describe the change"
   ```

4. Bump `versionId` in `modrinth.index.json` to match the release.
5. Tag the commit, for example `v1.1.0`.

The `.gitignore` keeps runtime state (logs, backups, JEI history, UI layouts) out of the repo. If a new mod writes junk into `config/`, add it there rather than committing it.

## Building a release file

An `.mrpack` is a zip with the index at the root. From the repo root:

```bash
zip -r -X ../AERO_SMP_TWO_v1.1.0.mrpack modrinth.index.json overrides
```

Upload the result as a new version on the Modrinth project page and attach it to a GitHub release. To roll back, check out an older tag and build the file the same way.

## Known issues and planned work

- Client-only jars are bundled for everyone. A `client-overrides/` folder would let the server skip them.
- Client settings such as video and keybind options are part of the overrides, so a pack update resets them for players.
- Shaders make up most of the file count. They are optional, and an extracted shader folder may be dropped from the repo later.

## Credits and licensing

All mods, shaders and resource packs belong to their authors and are used under their own licenses. Modrinth requires permission to include any content that is not your own in a modpack, so every jar bundled in `overrides/` needs its author's permission (or a license that allows it) before the pack is published.
