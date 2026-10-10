import Dates
import GitHub
import HTTP
import TimeZones

function _most_recent(
    registry::GitHub.Repo;
    api::GitHub.GitHubAPI,
    auth::GitHub.Authorization,
    workflow_file_name::AbstractString,
    event::AbstractString,
    get_json = GitHub.gh_get_json,
)
    # Scope the query to this workflow so other workflow dispatches cannot reset
    # the clock or push the last merge run out of the first API page.
    endpoint = "/repos/$(registry.full_name)/actions/workflows/$(workflow_file_name)/runs"
    params = Dict("branch" => "master", "event" => event, "per_page" => "1")
    json = get_json(api, endpoint; auth = auth, params = params)
    workflow_runs = json["workflow_runs"]
    isempty(workflow_runs) && return nothing
    workflow_run = first(workflow_runs)
    created_at = TimeZones.ZonedDateTime(
        workflow_run["created_at"],
        "yyyy-mm-ddTHH:MM:SSzzzz",
    )
    @info "# BEGIN information about the `workflow_run`"
    @info "" created_at
    for (key, value) in workflow_run
        @info "" key value
    end
    @info "# END information about the `workflow_run`"
    return created_at
end

function most_recent_automerge(
    registry::GitHub.Repo;
    api::GitHub.GitHubAPI,
    auth::GitHub.Authorization,
    get_json = GitHub.gh_get_json,
)
    latest = nothing
    for event in ("workflow_dispatch", "schedule")
        run_time = _most_recent(
            registry;
            api = api,
            auth = auth,
            workflow_file_name = "automerge_merge.yml",
            event = event,
            get_json = get_json,
        )
        if !isnothing(run_time) && (isnothing(latest) || run_time > latest)
            latest = run_time
        end
    end
    return latest
end

function time_since_last_automerge(
    registry::GitHub.Repo;
    api::GitHub.GitHubAPI,
    auth::GitHub.Authorization,
)
    last_automerge = most_recent_automerge(registry; api = api, auth = auth)
    isnothing(last_automerge) && return nothing
    now = TimeZones.now(TimeZones.localzone())
    return now - last_automerge
end

function trigger_new_workflow_dispatch(
    registry::GitHub.Repo;
    api::GitHub.GitHubAPI,
    auth::GitHub.Authorization,
    workflow_file_name::AbstractString,
)
    endpoint = "/repos/$(registry.full_name)/actions/workflows/$(workflow_file_name)/dispatches"
    params = Dict("ref" => "master")
    GitHub.gh_post(api, endpoint; auth = auth, params = params)
    return nothing
end

function _canonicalize(p::Dates.CompoundPeriod)
    return Dates.canonicalize(p)
end

function _canonicalize(p::Dates.Period)
    return _canonicalize(Dates.CompoundPeriod(p))
end

function trigger_new_automerge_if_necessary()
    api = GitHub.DEFAULT_API
    auth = GitHub.OAuth2(ENV["AUTOMERGE_MERGE_TOKEN"])
    registry = GitHub.Repo("JuliaRegistries/General")
    t = time_since_last_automerge(registry; api, auth)
    if isnothing(t)
        @info "No previous AutoMerge run; starting the first run"
    else
        @info "Time since last AutoMerge" t _canonicalize(t)
    end
    if isnothing(t) || t >= Dates.Minute(8)
        @info "Attempting to trigger a new AutoMerge workflow dispatch job..."
        trigger_new_workflow_dispatch(
            registry;
            api,
            auth,
            workflow_file_name = "automerge_merge.yml",
        )
        @info "Triggered a new AutoMerge workflow dispatch job"
    end
    return nothing
end

if abspath(PROGRAM_FILE) == @__FILE__
    trigger_new_automerge_if_necessary()
end
