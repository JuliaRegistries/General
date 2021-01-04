import Dates
import GitHub
import TimeZones

function _most_recent(registry::GitHub.Repo;
                      api::GitHub.GitHubAPI,
                      auth::GitHub.Authorization,
                      event::AbstractString,
                      workflow_name::AbstractString)
    endpoint = "/repos/$(registry.full_name)/actions/runs"
    params = Dict(
        "event" => event,
    )
    json = GitHub.gh_get_json(
        api,
        endpoint;
        auth = auth,
        params = params,
    )
    workflow_runs = json["workflow_runs"]
    for workflow_run in workflow_runs
        if workflow_run["name"] == workflow_name
            if workflow_run["event"] == event
                created_at = TimeZones.ZonedDateTime(
                    workflow_runs[1]["created_at"],
                    "yyyy-mm-ddTHH:MM:SSzzzz"
                )
                return created_at
            end
        end
    end
end

function most_recent_automerge(registry::GitHub.Repo;
                               api::GitHub.GitHubAPI,
                               auth::GitHub.Authorization)
    schedule = _most_recent(
        registry;
        api = api,
        auth = auth,
        event = "schedule",
        workflow_name = "AutoMerge"
    )
    workflow_dispatch = _most_recent(
        registry;
        api = api,
        auth = auth,
        event = "workflow_dispatch",
        workflow_name = "AutoMerge"
    )
    return max(schedule, workflow_dispatch)
end

function time_since_last_automerge(registry::GitHub.Repo;
                                   api::GitHub.GitHubAPI,
                                   auth::GitHub.Authorization)
    last_automerge = most_recent_automerge(registry; api = api, auth = auth)
    now = TimeZones.now(TimeZones.localzone())
    now - last_automerge
    return max(now - last_automerge, Dates.Millisecond(0))
end

function print_time_since_last_automerge()
    api = GitHub.DEFAULT_API
    # auth = GitHub.AnonymousAuth()
    auth = GitHub.authenticate(ENV["AUTOMERGE_TAGBOT_TOKEN"])
    registry = GitHub.repo(
        api,
        "JuliaRegistries/General";
        auth = auth,
    )
    t = time_since_last_automerge(registry; api, auth)
    @info "Time since last AutoMerge" t
    @info "Time since last AutoMerge (rounded down)" floor(t, Dates.Minute)
    @info "" t >= Dates.Minute(15)
    return nothing
end

print_time_since_last_automerge()
