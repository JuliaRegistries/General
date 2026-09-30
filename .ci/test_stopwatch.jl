using Test
include("stopwatch.jl")

@testset "AutoMerge stopwatch" begin
    registry = GitHub.Repo("JuliaRegistries/General")
    api = GitHub.DEFAULT_API
    auth = GitHub.OAuth2("unused-test-token")
    # A newer skipped PR from a fork's master branch must not reset the clock.
    runs = Dict(
        "workflow_dispatch" => [Dict("created_at" => "2026-09-30T10:00:00Z")],
        "schedule" => [Dict("created_at" => "2026-09-30T10:05:00Z")],
        "pull_request" => [Dict("created_at" => "2026-09-30T10:10:00Z")],
    )
    requested_events = String[]
    get_json = function (received_api, endpoint; auth, params)
        @test received_api === api
        @test endpoint == "/repos/JuliaRegistries/General/actions/workflows/automerge_merge.yml/runs"
        @test params["branch"] == "master"
        @test params["per_page"] == "1"
        event = get(params, "event", "pull_request")
        push!(requested_events, event)
        return Dict("workflow_runs" => runs[event])
    end
    @test most_recent_automerge(registry; api, auth, get_json) ==
        TimeZones.ZonedDateTime(2026, 9, 30, 10, 5, TimeZones.tz"UTC")
    @test requested_events == ["workflow_dispatch", "schedule"]

    # Also select the dispatch when it is newer.
    runs["workflow_dispatch"][1]["created_at"] = "2026-09-30T10:07:00Z"
    @test most_recent_automerge(registry; api, auth, get_json) ==
        TimeZones.ZonedDateTime(2026, 9, 30, 10, 7, TimeZones.tz"UTC")

    # Either event can have no history, or both can be absent on the first run.
    empty!(runs["workflow_dispatch"])
    @test most_recent_automerge(registry; api, auth, get_json) ==
        TimeZones.ZonedDateTime(2026, 9, 30, 10, 5, TimeZones.tz"UTC")
    empty!(runs["schedule"])
    @test isnothing(most_recent_automerge(registry; api, auth, get_json))
    push!(runs["workflow_dispatch"], Dict("created_at" => "2026-09-30T10:07:00Z"))
    @test most_recent_automerge(registry; api, auth, get_json) ==
        TimeZones.ZonedDateTime(2026, 9, 30, 10, 7, TimeZones.tz"UTC")
end
