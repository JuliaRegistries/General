# AutoMerge deployment

General's AutoMerge jobs are defined in `.github/workflows/`; their Julia
dependencies are recorded in `.ci/AutoMerge/` and `.ci/`. Updates to these files
take effect for subsequent registration PRs and scheduled runs after they are
merged into `master`. On a deployment PR, the check jobs use the PR's checkout;
the stopwatch explicitly checks out `master`.

## Registration flow

1. Registrator opens or updates a registration PR in General.
2. `automerge_check.yml` calls `AutoMerge.check_pr()` to check the package and post
   its decision and explanation. A separate label job reruns checks when a relevant
   override label is added. Fork PRs do not run these checks.
   `registry-consistency-ci.yml` separately checks registry structure and metadata;
   `automerge_staging.yml` runs read-only checks against AutoMerge's `master`.
3. `automerge_stopwatch.yml` checks merge-run history on PR activity and dispatches
   `automerge_merge.yml` when at least eight minutes have passed since its latest
   scheduled or manually dispatched run. It starts the first run if history is empty.
4. `automerge_merge.yml` calls `AutoMerge.merge_prs()` on scheduled or manually
   dispatched runs on `master`. It checks the approval for the current commit,
   waiting period, and blocking comments before merging.
5. `TagBotTriggers.yml` uses the merged-PR event to notify the package repository's
   TagBot. A scheduled run provides a fallback, including for manually merged PRs.

The stopwatch runs [`../../.ci/stopwatch.jl`](../../.ci/stopwatch.jl) from `master`.
The merge workflow is also scheduled every four hours. The stopwatch can trigger
additional runs, but does not guarantee a run every eight minutes. It uses the
GitHub Actions environment named `stopwatch`; any required approvals can delay
the job.

## Staging and production

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
3. Update production's project and regenerate every manifest used by its jobs.
   A Git source pins the selected revision; a registered dependency is locked
   by the manifest. Keep `update_manifests.yml`'s Julia matrix in sync.
4. Merge the General deployment PR, then verify checking on a registration PR,
   a merge run on `master`, stopwatch dispatch, and a TagBot notification. Workflow
   success on the deployment PR alone does not exercise all of these paths.

`GITHUB_TOKEN` handles PR checks; `TAGBOT_TOKEN` supplies privileged merging,
workflow dispatch, and TagBot operations. Preserve this separation when editing
workflows. To roll back, revert the deployment changes and their dependency
manifests together.
