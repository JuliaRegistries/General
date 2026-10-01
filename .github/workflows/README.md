# AutoMerge deployment

General's AutoMerge jobs are defined in `.github/workflows/`; their Julia
dependencies are recorded in `.ci/AutoMerge/` and `.ci/`. Updates to these files
take effect for subsequent registration PRs and scheduled runs after they are
merged into `master`. On a PR that changes these workflows or dependencies, the
check jobs use the PR's checkout; the stopwatch explicitly checks out `master`.

## Registration flow

1. Registrator opens or updates a registration PR in General.
2. `automerge_check.yml` calls `AutoMerge.check_pr()` to check the registration
   against AutoMerge's guidelines. It posts an `automerge/decision` commit status
   on the PR's head commit: `pending` while checking, then `success` or `failure`.
   A successful status's description records the registration type, package name,
   and approved commit SHA for the merge job to verify. It also posts or updates
   a PR comment explaining the result. A separate label job reruns checks when a
   relevant override label is added. Fork PRs do not run these checks.
   `registry-consistency-ci.yml` separately checks registry structure and metadata;
   `automerge_staging.yml` runs read-only checks against AutoMerge's `master`.
3. `automerge_stopwatch.yml` checks merge-run history on PR activity and dispatches
   `automerge_merge.yml` when at least eight minutes have passed since its latest
   scheduled or manually dispatched run. It starts the first run if history is empty.
4. `automerge_merge.yml` calls `AutoMerge.merge_prs()` on scheduled or manually
   dispatched runs on `master`. It iterates over open PRs, requiring an authorized
   author, a registration title, and an elapsed waiting period. It reads the
   `automerge/decision` commit status, requires `success`, and verifies that the
   approved package name and commit SHA match the PR. It also requires any
   additional configured statuses and check runs to pass and checks for blocking
   comments, unless the blocking-comment override label is present. It
   squash-merges eligible PRs, passing the approved SHA to GitHub so that a newer,
   unchecked commit cannot be merged instead.
5. `TagBotTriggers.yml` uses the merged-PR event to notify the package repository's
   TagBot. A scheduled run provides a fallback, including for manually merged PRs.

The stopwatch was added to reduce delays caused by unreliable GitHub Actions
schedules: scheduled merge runs could be hours late, as described in
[General issue #107794](https://github.com/JuliaRegistries/General/issues/107794#issuecomment-2137023829).
It uses PR activity to trigger merge runs without waiting for the schedule. It
does not check or merge the PR that triggered it; the merge job examines all open
PRs. The stopwatch runs [`../../.ci/stopwatch.jl`](../../.ci/stopwatch.jl) from `master`.
The merge workflow is also scheduled every four hours. The stopwatch can trigger
additional runs, but does not guarantee a run every eight minutes. It uses the
GitHub Actions environment named `stopwatch`; any required approvals can delay
the job.

## Staging and production

General keeps two Julia environments, each with its own `Project.toml` and
version-specific `Manifest-v*.toml` files:

- `.ci/` supplies RegistryCI for `registry-consistency-ci.yml` and
  `registry-consistency-ci-cron.yml`, which call `RegistryCI.test()` on Julia
  1.3–1.13. It also supplies the stopwatch's dependencies.
- `.ci/AutoMerge/` supplies AutoMerge and its RegistryCI dependency for production
  registration checks, merging, and TagBot on Julia 1.12–1.13.

These environments resolve dependencies independently. Updating RegistryCI in
one does not update the other. **Update Manifests** updates both environments;
their compat bounds determine which releases it can select.

- `automerge_staging.yml` installs standalone AutoMerge from the `AutoMerge/`
  subdirectory of RegistryCI's `master`, resolves fresh dependencies, and runs
  read-only PR checks. It does not publish approvals, comments, or merges.
  Inspect its logs to compare checks from AutoMerge's `master` with production.
- Production checking, merging, and TagBot use standalone AutoMerge from
  `.ci/AutoMerge`, with checked-in version-specific manifests.
  Check jobs run package code without the merge token; merge jobs receive that
  token and do not install or load proposed packages.

## Rolling out an update

1. Review the RegistryCI/AutoMerge changes and use **Registrator** to register
   releases. The two packages share a repository but have separate versions;
   standalone AutoMerge registrations use `subdir=AutoMerge`.
2. Observe staging for about a day. Each run installs AutoMerge from RegistryCI's
   `master`, so confirm which revision each run tested if new commits were merged.
3. If the release is outside the relevant project's compat bounds, merge a PR
   updating those bounds first. Then run **Update Manifests** (`update_manifests.yml`)
   on `master`, either from the Actions page or with:

   ```sh
   gh api --method POST \
     repos/JuliaRegistries/General/actions/workflows/update_manifests.yml/dispatches \
     -f ref=master
   ```

   It updates dependencies in `.ci/` and `.ci/AutoMerge/` for each Julia version
   in its matrices and opens or updates a PR with the resulting manifests.
   Review that PR and confirm it selects the intended RegistryCI or AutoMerge
   release. Keep the action's Julia matrices in sync with the versions used by
   the other workflows.
4. Merge the PR updating General's workflows or dependencies, then verify checking
   on a registration PR, a merge run on `master`, stopwatch dispatch, and a TagBot
   notification. Workflow
   success on the workflow or dependency update PR alone does not exercise all
   of these paths.

`GITHUB_TOKEN` handles PR checks; `TAGBOT_TOKEN` supplies privileged merging,
workflow dispatch, and TagBot operations. Preserve this separation when editing
workflows. To roll back, revert the workflow and dependency changes together.
