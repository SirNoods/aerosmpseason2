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

The pack is published on Modrinth: <!-- Projlink -->

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

4. Push the commit, then tag it (see Versioning below).

The `.gitignore` keeps runtime state (logs, backups, JEI history, UI layouts) out of the repo. If a new mod writes junk into `config/`, add it there rather than committing it.

## Versioning and releases

Tags use semantic versioning with a `v` prefix: `vMAJOR.MINOR.PATCH`, plus an optional pre-release suffix.

| Tag | Release type on Modrinth | Use it for |
|---|---|---|
| `v1.4.0-alpha.1` | alpha | rough work in progress, may break worlds |
| `v1.4.0-beta.1` | beta | candidate for testing with the group |
| `v1.4.0` | release | the version players should be on |

What the numbers mean:

- **MAJOR:** changes that can break existing worlds, such as removing a mod, a Minecraft or loader version change, or a rebalance that invalidates builds. Players should expect to read the changelog first.
- **MINOR:** new mods or content, or notable recipe and config changes. Safe for existing worlds.
- **PATCH:** mod version bumps, config tweaks and bug fixes.

Typical flow: tag `v1.4.0-beta.1`, test it, fix what you find and tag `v1.4.0-beta.2`, then tag `v1.4.0` once it is good. Moving a pre-release to a full release means a new tag, so the final release is always built from a commit that was tagged on purpose.

Pushing a tag starts the release workflow in `.github/workflows/release.yml`. It stamps the version into `modrinth.index.json`, builds the `.mrpack`, uploads it to Modrinth and attaches it to a GitHub release. The release type is read from the tag suffix. You do not need to edit `versionId` by hand.

```bash
git tag v1.4.0-beta.1
git push origin v1.4.0-beta.1
```

If a run fails before anything was uploaded, delete the tag and push it again:

```bash
git tag -d v1.4.0-beta.1
git push --delete origin v1.4.0-beta.1
```

To build a file by hand, an `.mrpack` is a zip with the index at the root:

```bash
zip -r -X ../AERO_SMP_TWO_v1.4.0.mrpack modrinth.index.json overrides
```

To roll back, check out an older tag and build the file the same way.

## Known issues and planned work

- Client-only jars are bundled for everyone. A `client-overrides/` folder would let the server skip them.
- Client settings such as video and keybind options are part of the overrides, so a pack update resets them for players.
- Shaders make up most of the file count. They are optional, and an extracted shader folder may be dropped from the repo later.

## Credits and licensing

All mods, shaders and resource packs belong to their authors and are used under their own licenses. Modrinth requires permission to include any content that is not your own in a modpack, so every jar bundled in `overrides/` needs its author's permission (or a license that allows it) before the pack is published.
