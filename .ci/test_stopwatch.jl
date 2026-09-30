using Test
include("stopwatch.jl")

@testset "AutoMerge stopwatch" begin
    registry = GitHub.Repo("JuliaRegistries/General")
    api = GitHub.DEFAULT_API
    auth = GitHub.OAuth2("unused-test-token")
    get_json = function (received_api, endpoint; auth, params)
        @test received_api === api
        @test endpoint == "/repos/JuliaRegistries/General/actions/workflows/automerge.yml/runs"
        @test params == Dict("branch" => "master", "per_page" => "1")
        return Dict("workflow_runs" => [Dict("created_at" => "2026-09-30T10:00:00Z")])
    end
    @test most_recent_automerge(registry; api, auth, get_json) ==
        TimeZones.ZonedDateTime(2026, 9, 30, 10, TimeZones.tz"UTC")

    # No run history is a normal first-run condition.
    empty_runs = (args...; kwargs...) -> Dict("workflow_runs" => [])
    @test isnothing(most_recent_automerge(registry; api, auth, get_json = empty_runs))
end
