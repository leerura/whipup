#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ "$PWD" != "$repo_root" ]]; then
  echo "Run this script from the repository root: $repo_root" >&2
  exit 2
fi

if [[ "${ALLOW_WHIPUP_LOCAL_DB_RESET:-}" != "YES" ]]; then
  echo "This removes every Docker volume attached to this repository's Compose project, including local users/auth data." >&2
  echo "Afterward it starts backend/PostgreSQL so Flyway creates a fresh schema. It does not import the current V2 dataset." >&2
  echo "To confirm, rerun from the repository root with ALLOW_WHIPUP_LOCAL_DB_RESET=YES." >&2
  exit 2
fi

compose=(docker compose --project-directory "$repo_root" -f "$repo_root/compose.yaml")
"${compose[@]}" down --volumes --remove-orphans
"${compose[@]}" up --build -d backend

echo "Fresh local V3 schema is starting. Wait for backend health before importing a V3 dataset."
