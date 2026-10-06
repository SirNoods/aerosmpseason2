# AERO SMP TWO

Modpack for the aeronautics SMP: Create, Create Aeronautics, Sable physics, CC: Tweaked and a long tail of addons.

| | |
|---|---|
| Minecraft | 1.21.1 |
| Loader | NeoForge 21.1.252 |
| Format | CurseForge modpack (`.zip` with `manifest.json`) |
| Maintained in | CurseForge app or Prism Launcher, exported as a CurseForge pack |

## How this repo works

The pack is designed and tested in a launcher. This repo holds the unzipped contents of each CurseForge export, so git can show exactly what changed between versions.

```
manifest.json         Minecraft and loader version, plus every mod as a CurseForge project and file ID
overrides/
  config/             mod configs
  kubejs/             recipe and script changes
  mods/               jars bundled directly (mods that are not on CurseForge, such as voxy)
  resourcepacks/
  shaderpacks/
```

Mods listed in `manifest.json` are downloaded from CurseForge by the launcher and are not stored in this repo. Anything in `overrides/` is copied into the instance as-is, so it replaces any local file with the same name.

## Installing (players)

The pack is published on CurseForge: <!-- add the project link here -->

- **CurseForge app:** open the pack's page and press Install.
- **Prism Launcher:** Add Instance, then the CurseForge tab, and search for the pack.

Some mod authors turn off downloads outside the CurseForge app. If Prism lists mods it could not download, open each link it shows, download the file by hand and point Prism at it. This is expected, not a broken install.

Fallback: download the `.zip` from this repo's Releases page and use Add Instance, Import in Prism.

## Installing (server)

Use the server host's CurseForge modpack installer and pick this pack. If your host has no such option, a tool that builds a server pack from a CurseForge zip, such as ServerPackCreator, can do it; check its documentation for current usage. Mods whose authors block outside downloads may need to be added to the server by hand.

Known issue: CurseForge packs cannot mark mods as client-only, so client-side mods are installed on the server too. Remove them from the server's `mods` folder after installing. Examples:

- `voxy` (a Fabric mod that runs through Sinytra Connector, kept on purpose for now)
- `dlss-style`
- `ToastControl`
- `gpumemleakfix`
- `clientcrafting`
- `flashback_aero`

This list is a starting point, not exhaustive. Shaders and resource packs are optional on the server and can be deleted.

## Updating the pack (maintainers)

1. Make your changes in the launcher and test them.
2. Export the instance as a CurseForge pack. In the CurseForge app that is the profile's export option. In Prism it is Export Instance, then the CurseForge format.
3. In this repo, wipe the old contents and unzip the new export, so deleted files do not linger:

   ```bash
   rm -rf overrides manifest.json modlist.html
   unzip -q AERO_SMP_TWO_X.zip
   git add -A
   git commit -m "Describe the change"
   ```

4. Push the commit, then tag it (see Versioning below).

The `.gitignore` keeps runtime state (logs, backups, JEI history, UI layouts) out of the repo. If a new mod writes junk into `config/`, add it there rather than committing it.

## Versioning and releases

Tags use semantic versioning with a `v` prefix: `vMAJOR.MINOR.PATCH`, plus an optional pre-release suffix.

| Tag | Release type on CurseForge | Use it for |
|---|---|---|
| `v1.4.0-alpha.1` | alpha | rough work in progress, may break worlds |
| `v1.4.0-beta.1` | beta | candidate for testing with the group |
| `v1.4.0` | release | the version players should be on |

What the numbers mean:

- **MAJOR:** changes that can break existing worlds, such as removing a mod, a Minecraft or loader version change, or a rebalance that invalidates builds. Players should expect to read the changelog first.
- **MINOR:** new mods or content, or notable recipe and config changes. Safe for existing worlds.
- **PATCH:** mod version bumps, config tweaks and bug fixes.

Typical flow: tag `v1.4.0-beta.1`, test it, fix what you find and tag `v1.4.0-beta.2`, then tag `v1.4.0` once it is good. Moving a pre-release to a full release means a new tag, so the final release is always built from a commit that was tagged on purpose.

Pushing a tag starts the release workflow in `.github/workflows/release.yml`. It stamps the version into `manifest.json`, builds the pack zip, uploads it to CurseForge and attaches it to a GitHub release. The release type is read from the tag suffix. You do not need to edit the version in `manifest.json` by hand.

```bash
git tag v1.4.0-beta.1
git push origin v1.4.0-beta.1
```

If a run fails before anything was uploaded, delete the tag and push it again:

```bash
git tag -d v1.4.0-beta.1
git push --delete origin v1.4.0-beta.1
```

To build a file by hand, a CurseForge pack is a zip with the manifest at the root:

```bash
zip -r -X ../AERO_SMP_TWO_v1.4.0.zip manifest.json overrides
```

To roll back, check out an older tag and build the file the same way.

## For maintainers on Windows (GitHub Desktop)

GitHub Desktop is the easiest way to work with this repo if you have not used git before.

One-time setup:

1. Ask the repo owner to add you as a collaborator (Settings, Collaborators) and accept the email invite.
2. Install GitHub Desktop and sign in with your GitHub account.
3. File, Clone repository, pick `SirNoods/aerosmpseason2`, and choose a folder.

Each time you change the pack:

1. Open GitHub Desktop and press Fetch origin, then Pull if it offers it. This brings in the other maintainer's changes and avoids most conflicts.
2. Make and test your changes in the CurseForge app.
3. Export the profile as a CurseForge zip. In the export dialog, untick saves and screenshots.
4. In the repo folder, delete `overrides`, `manifest.json` and `modlist.html`. Leave `.git`, `.github`, `.gitignore` and the README alone. Then unzip the export into the folder. Deleting first matters, because otherwise removed files stay in the repo.
5. GitHub Desktop lists the changed files on the left. Write a short summary in plain words, since commit messages become the changelog, then press Commit to main.
6. Press Push origin.

Releasing:

1. In the History tab, right-click the commit to release and choose Create tag. Type the version, for example `v0.2.0-beta.1`.
2. Press Push origin again. Desktop pushes tags along with the commits.
3. The workflow starts by itself. Watch it on GitHub under the Actions tab.

Ground rules:

- Agree on one person who tags releases, so you do not both publish at once.
- Always use the `v` prefix and the suffix scheme above.
- Before pushing, check that the file list does not include a world save or any file over 100 MB. GitHub rejects pushes with files that large.
- Never reuse a version name that is already on CurseForge. If a release goes wrong, tell the other maintainer before deleting a tag.

## Setting up the workflow

1. Create the modpack project in CurseForge for Creators and note its numeric project ID.
2. Put that ID in `CURSEFORGE_PROJECT_ID` in `.github/workflows/release.yml`.
3. Create an API token in CurseForge for Creators and save it as a repo secret named `CURSEFORGE_TOKEN` (Settings, Secrets and variables, Actions).
4. Try a first tag such as `v0.1.0-beta.1` against the draft project before a real release.

## Known issues and planned work

- Client-only mods are installed for everyone, including the server, because CurseForge packs have no client-only flag.
- Mods that block downloads outside the CurseForge app need a manual step in Prism and on some server hosts.
- Client settings such as video and keybind options are part of the overrides, so a pack update resets them for players.
- Shaders make up most of the file count. They are optional, and an extracted shader folder may be dropped from the repo later.

## Credits and licensing

All mods, shaders and resource packs belong to their authors and are used under their own licenses. Mods listed in `manifest.json` are downloaded from CurseForge and are not redistributed by this repo. Anything bundled in `overrides/` is redistributed with the pack, so it needs its author's permission or a license that allows it. Keep that list short.
