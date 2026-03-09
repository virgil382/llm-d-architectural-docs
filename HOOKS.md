**Local hooks: update 'Last Update' before push**

- Purpose: Run a local pre-push hook to update "Last Update:" lines in key markdown files and commit them before pushing. This prevents CI from making commits that you don't have locally.

How to enable (one-time per clone):

- Windows (PowerShell):

  Run in repository root:

  ```powershell
  .\scripts\setup-hooks.ps1
  ```

- macOS / Linux (bash):

  Run in repository root:

  ```bash
  git config core.hooksPath .githooks
  ```

Notes:

- The repository now includes `.githooks/pre-push` (bash) and `.githooks/pre-push.ps1` (PowerShell). These are tracked so collaborators can enable them with the commands above.
- The CI workflow `.github/workflows/update-last-update.yml` has been adjusted to stop pushing changes from the runner.
- If you prefer a different workflow (e.g., automatic setup on `make` or `npm ci`), I can add that next.
