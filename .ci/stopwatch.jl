import Dates
import GitHub
import HTTP
import TimeZones

function _most_recent(
    registry::GitHub.Repo;
    api::GitHub.GitHubAPI,
    auth::GitHub.Authorization,
    event::AbstractString,
    workflow_name::AbstractString,
)
    endpoint = "/repos/$(registry.full_name)/actions/runs"
    params = Dict("event" => event)
    json = GitHub.gh_get_json(api, endpoint; auth = auth, params = params)
    workflow_runs = json["workflow_runs"]
    for workflow_run in workflow_runs
        if workflow_run["name"] == workflow_name
            if workflow_run["event"] == event
                created_at = TimeZones.ZonedDateTime(
                    workflow_runs[1]["created_at"],
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
        end
    end
    throw(ErrorException("I could not figure out when the most recent job was"))
end

function most_recent_automerge(
    registry::GitHub.Repo;
    api::GitHub.GitHubAPI,
    auth::GitHub.Authorization,
)
    workflow_dispatch = _most_recent(
        registry;
        api = api,
        auth = auth,
        event = "workflow_dispatch",
        workflow_name = "AutoMerge",
    )
    return workflow_dispatch
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

trigger_new_automerge_if_necessary()
