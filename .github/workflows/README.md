# AutoMerge deployment

Deployment means changing the workflows and their Julia dependency environments
on General's `master` branch. PR checks exercise the proposed configuration;
scheduled workflows use the configuration already merged into `master`.

## Registration flow

1. Registrator opens or updates a registration PR in General.
2. AutoMerge checks the package, posts its decision and explanation, and reruns
   when a relevant override label is added. Fork PRs do not run these checks.
3. Scheduled or manually dispatched merge runs check the approval for the current
   commit, waiting period, and blocking comments before merging.
4. `TagBotTriggers.yml` uses the merged-PR event to notify the package repository's
   TagBot. A scheduled run provides a fallback, including for manually merged PRs.

The stopwatch (`../../.ci/stopwatch.jl`) checks the latest scheduled or manually
dispatched AutoMerge run. PR activity provides polling opportunities: after
eight minutes it dispatches another run on `master`. With little PR activity,
the four-hour merge schedule is the fallback; eight minutes is not a guaranteed
interval. The stopwatch uses the `stopwatch` environment, whose approval rules
can delay polling.

## Staging and production

- `automerge_staging.yml` installs standalone AutoMerge from the `AutoMerge/`
  subdirectory of RegistryCI's `master`, resolves fresh dependencies, and runs
  read-only PR checks. It does not publish approvals, comments, or merges.
  Inspect its logs to compare proposed behavior with production.
- Production uses checked-in version-specific manifests. Currently,
  `automerge.yml` calls `RegistryCI.AutoMerge.run()` from the `.ci` environment.
- The [standalone AutoMerge migration](https://github.com/JuliaRegistries/General/pull/170048)
  replaces that workflow with `automerge_check.yml`, `automerge_merge.yml`, and
  `automerge_stopwatch.yml`, and moves AutoMerge/TagBot to `.ci/AutoMerge`.
  Check jobs run package code without the merge token; merge jobs receive that
  token and do not install or load proposed packages.

## Rolling out an update

1. Review the RegistryCI/AutoMerge changes and use **Registrator** to register
   releases. The two packages share a repository but have separate versions;
   standalone AutoMerge registrations use `subdir=AutoMerge`.
2. Observe master-tracking staging for about a day. Staging can change when new
   commits land in RegistryCI, so confirm which code its logs tested.
3. Update production's project and regenerate every manifest used by its jobs.
   A Git source pins the selected revision; a registered dependency is locked
   by the manifest. Keep `update_manifests.yml`'s Julia matrix in sync.
4. Merge the General deployment PR, then verify checking on a registration PR,
   a merge run on `master`, stopwatch dispatch, and TagBot triggering. Workflow
   success on the deployment PR alone does not exercise all of these paths.

`GITHUB_TOKEN` handles PR checks; `TAGBOT_TOKEN` supplies privileged merging,
workflow dispatch, and TagBot operations. Preserve this separation when editing
workflows. To roll back, revert the deployment changes and their dependency
manifests together.
