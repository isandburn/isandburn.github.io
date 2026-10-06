# Skills

Published agent skills (Agent Skills format) for opencode.
This file is the single source for release facts: version, checksum, versioned archive.
Per-skill detail lives at `/skills/<name>.md`.

## typesafe-ai

Typed AI decisions — judgments (`noul`), choices (`choice`), and scores (`score`) —
run against the Typesafe System One (Jev) models. The bundled bash CLI (`jev`)
builds, validates, and executes decision trees.

- **Card:** [skills/typesafe-ai.md](/skills/typesafe-ai.md)
- **Version:** 0.1.0
- **Updated:** 2026-10-05
- **Archive:** <https://isandburn.github.io/skills/typesafe-ai-0.1.0.zip>
- **Checksum:** sha256 485563bfcb787a44e12837f4a883a7cd872adc5ee961679ee91a8c7fcaab013d

Install (global):

    curl -fsSL https://isandburn.github.io/skills/typesafe-ai.zip | unzip -o -d ~/.config/opencode/skills

Install (project-local):

    curl -fsSL https://isandburn.github.io/skills/typesafe-ai.zip | unzip -o -d .opencode/skills
