# skills/

Personal package index for agent skills. Plain static files, no build step.
Everything here is public.

## Layout

    skills/
      index.html                    catalog page (published at /skills/)
      <name>-<version>.zip          versioned archive, kept forever
      <name>-<version>.zip.sha256   checksum sidecar
      <name>.zip                    "latest" copy of the current release (overwritten)

## Zip rules

- One top-level folder named exactly like the skill's `name` frontmatter field
  (e.g. `typesafe-ai/SKILL.md`), so unzipping into any skills directory works.
- Built only from committed content of the skill's own repo — never from a dirty
  tree, never from the repo root. No secrets, no `.env`, no local state.

## Publishing a skill (or a new version)

1. In the skill repo: bump `metadata.version` in `SKILL.md` frontmatter; commit.
2. From a clean checkout, archive the committed skill folder (top-level folder
   must be the skill name):

       git archive --format=zip --prefix=<name>/ HEAD:<path-to-skill-folder> -o <name>-<version>.zip
       sha256sum <name>-<version>.zip > <name>-<version>.zip.sha256

3. Copy into `skills/` and refresh the latest copy:

       cp <name>-<version>.zip <name>-<version>.zip.sha256 skills/
       cp <name>-<version>.zip skills/<name>.zip

4. Add or refresh the row in `skills/index.html` (name, description, version,
   date, links) and update the install/verify one-liners for the new version if
   they reference one.
5. Hygiene check before publishing:

       unzip -l <name>-<version>.zip

   Confirm the single top-level folder and that nothing unexpected is inside.
6. Commit and push to `main` — GitHub Pages is live within a minute.
7. Verify the live artifact:

       curl -fsSL https://isandburn.github.io/skills/<name>-<version>.zip | sha256sum

   and compare against the published sidecar.
