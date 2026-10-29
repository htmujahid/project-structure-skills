#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "usage: $0 <skill-name>" >&2
  exit 1
fi

name="$1"
if ! [[ "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "error: name must be kebab-case (lowercase letters, digits, hyphens)" >&2
  exit 1
fi

root="$(cd "$(dirname "$0")/.." && pwd)"
dest="$root/skills/$name"

if [ -e "$dest" ]; then
  echo "error: $dest already exists" >&2
  exit 1
fi

cp -R "$root/_template" "$dest"
sed -i.bak "s/{NAME}/$name/g" "$dest/SKILL.md" && rm "$dest/SKILL.md.bak"

cat <<EOF
Created skills/$name/

Next steps:
  1. Edit skills/$name/SKILL.md: replace {FRAMEWORK}, {VERSION}, {DATE} and every "Fill in:" line.
  2. Fill in skills/$name/references/ (full-tree.md, anti-patterns.md, growth-stages.md).
  3. Delete the comment block at the top of SKILL.md.
  4. Validate: npx skills add ./ --list
  5. Add a row to the Skills table in README.md.

Required (already created): SKILL.md, references/full-tree.md,
  references/anti-patterns.md, references/growth-stages.md.
Optional, add only when needed and never empty (see docs/skill-anatomy.md):
  assets/      files to copy into the project
  examples/    small complete layouts
  scripts/     helpers runnable with the framework's own toolchain
  evals/       prompts and expected outcomes
  agents/openai.yaml   UI metadata
Every optional folder must be mentioned in SKILL.md.
EOF
