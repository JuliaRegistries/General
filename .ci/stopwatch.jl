import Dates
import GitHub
import HTTP
import TimeZones

function most_recent_automerge(
    registry::GitHub.Repo;
    api::GitHub.GitHubAPI,
    auth::GitHub.Authorization,
    workflow_file_name::AbstractString = "automerge.yml",
    get_json = GitHub.gh_get_json,
)
    # Scope the query to this workflow so other workflow dispatches cannot reset
    # the clock or push the last merge run out of the first API page.
    endpoint = "/repos/$(registry.full_name)/actions/workflows/$(workflow_file_name)/runs"
    params = Dict("branch" => "master", "per_page" => "1")
    json = get_json(api, endpoint; auth = auth, params = params)
    workflow_runs = json["workflow_runs"]
    isempty(workflow_runs) && throw(ErrorException("I could not figure out when the most recent job was"))
    workflow_run = first(workflow_runs)
    created_at = TimeZones.ZonedDateTime(
        workflow_run["created_at"],
        "yyyy-mm-ddTHH:MM:SSzzzz",
    )
    @info "Most recent AutoMerge merge run" created_at
    return created_at
end

function time_since_last_automerge(
    registry::GitHub.Repo;
    api::GitHub.GitHubAPI,
    auth::GitHub.Authorization,
)
    last_automerge = most_recent_automerge(registry; api = api, auth = auth)
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
    auth = GitHub.OAuth2(ENV["AUTOMERGE_TAGBOT_TOKEN"])
    registry = GitHub.Repo("JuliaRegistries/General")
    t = time_since_last_automerge(registry; api, auth)
    @info "Time since last AutoMerge" t _canonicalize(t)
    if t >= Dates.Minute(8)
        @info "Attempting to trigger a new AutoMerge workflow dispatch job..."
        trigger_new_workflow_dispatch(
            registry;
            api,
            auth,
            workflow_file_name = "automerge.yml",
        )
        @info "Triggered a new AutoMerge workflow dispatch job"
    end
    return nothing
end

if abspath(PROGRAM_FILE) == @__FILE__
    trigger_new_automerge_if_necessary()
end
