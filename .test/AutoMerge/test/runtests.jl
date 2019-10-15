using AutoMerge
using Pkg
using Test

@testset "AutoMerge.jl" begin
    @testset "Unit tests" begin
        @testset "Guidelines for new packages" begin
            @testset "Normal capitalization" begin
                @test AutoMerge.meets_normal_capitalization("Zygote")[1]
                @test AutoMerge.meets_normal_capitalization("Zygote")[1]
                @test !AutoMerge.meets_normal_capitalization("HTTP")[1]
                @test !AutoMerge.meets_normal_capitalization("HTTP")[1]
            end
            @testset "Not too short - at least five letters" begin
                @test AutoMerge.meets_name_length("Zygote")[1]
                @test AutoMerge.meets_name_length("Zygote")[1]
                @test !AutoMerge.meets_name_length("Flux")[1]
                @test !AutoMerge.meets_name_length("Flux")[1]
            end
            @testset "Standard initial version number" begin
                @test AutoMerge.meets_standard_initial_version_number(v"0.0.1")[1]
                @test AutoMerge.meets_standard_initial_version_number(v"0.1.0")[1]
                @test AutoMerge.meets_standard_initial_version_number(v"1.0.0")[1]
                @test !AutoMerge.meets_standard_initial_version_number(v"0.0.2")[1]
                @test !AutoMerge.meets_standard_initial_version_number(v"0.1.1")[1]
                @test !AutoMerge.meets_standard_initial_version_number(v"0.2.0")[1]
                @test !AutoMerge.meets_standard_initial_version_number(v"1.0.1")[1]
                @test !AutoMerge.meets_standard_initial_version_number(v"1.1.0")[1]
                @test !AutoMerge.meets_standard_initial_version_number(v"1.1.1")[1]
                @test !AutoMerge.meets_standard_initial_version_number(v"2.0.0")[1]
            end
            @testset "Repo URL ends with /name.jl.git where name is the package name" begin
                @test AutoMerge.url_has_correct_ending("https://github.com/FluxML/Flux.jl.git", "Flux")[1]
                @test !AutoMerge.url_has_correct_ending("https://github.com/FluxML/Flux.jl", "Flux")[1]
                @test !AutoMerge.url_has_correct_ending("https://github.com/FluxML/Zygote.jl.git", "Flux")[1]
                @test !AutoMerge.url_has_correct_ending("https://github.com/FluxML/Zygote.jl", "Flux")[1]
            end
        end
        @testset "Guidelines for new versions" begin
            @testset "Sequential version number" begin
                @test AutoMerge.meets_sequential_version_number(v"0.0.1", v"0.0.2")[1]
                @test AutoMerge.meets_sequential_version_number(v"0.1.0", v"0.1.1")[1]
                @test AutoMerge.meets_sequential_version_number(v"0.1.0", v"0.2.0")[1]
                @test AutoMerge.meets_sequential_version_number(v"1.0.0", v"1.0.1")[1]
                @test AutoMerge.meets_sequential_version_number(v"1.0.0", v"1.1.0")[1]
                @test AutoMerge.meets_sequential_version_number(v"1.0.0", v"2.0.0")[1]
                @test !AutoMerge.meets_sequential_version_number(v"0.0.1", v"0.0.3")[1]
                @test !AutoMerge.meets_sequential_version_number(v"0.1.0", v"0.3.0")[1]
                @test !AutoMerge.meets_sequential_version_number(v"1.0.0", v"1.0.2")[1]
                @test !AutoMerge.meets_sequential_version_number(v"1.0.0", v"1.2.0")[1]
                @test !AutoMerge.meets_sequential_version_number(v"1.0.0", v"3.0.0")[1]
                @test AutoMerge.meets_sequential_version_number(v"0.1.1", v"0.2.0")[1]
                @test AutoMerge.meets_sequential_version_number(v"0.1.2", v"0.2.0")[1]
                @test AutoMerge.meets_sequential_version_number(v"0.1.3", v"0.2.0")[1]
                @test AutoMerge.meets_sequential_version_number(v"1.0.1", v"1.1.0")[1]
                @test AutoMerge.meets_sequential_version_number(v"1.0.2", v"1.1.0")[1]
                @test AutoMerge.meets_sequential_version_number(v"1.0.3", v"1.1.0")[1]
                @test !AutoMerge.meets_sequential_version_number(v"0.1.1", v"0.2.1")[1]
                @test !AutoMerge.meets_sequential_version_number(v"0.1.2", v"0.2.2")[1]
                @test !AutoMerge.meets_sequential_version_number(v"1.0.1", v"1.1.1")[1]
                @test !AutoMerge.meets_sequential_version_number(v"1.0.3", v"1.2.0")[1]
                @test !AutoMerge.meets_sequential_version_number(v"1.0.3", v"1.2.1")[1]
                @test !AutoMerge.meets_sequential_version_number(v"1.0.3", v"1.1.1")[1]
                @test !AutoMerge.meets_sequential_version_number(v"1.0.0", v"2.0.1")[1]
                @test !AutoMerge.meets_sequential_version_number(v"1.0.0", v"2.1.0")[1]
                @test !AutoMerge.meets_sequential_version_number(v"1.0.0", v"2.1.0")[1]
            end
            @testset "Patch releases cannot narrow Julia compat" begin
                r1 = Pkg.Types.VersionRange("1.3-1.7")
                r2 = Pkg.Types.VersionRange("1.4-1.7")
                r3 = Pkg.Types.VersionRange("1.3-1.6")
                @test AutoMerge.range_did_not_narrow(r1, r1)[1]
                @test AutoMerge.range_did_not_narrow(r2, r2)[1]
                @test AutoMerge.range_did_not_narrow(r3, r3)[1]
                @test AutoMerge.range_did_not_narrow(r2, r1)[1]
                @test AutoMerge.range_did_not_narrow(r3, r1)[1]
                @test !AutoMerge.range_did_not_narrow(r1, r2)[1]
                @test !AutoMerge.range_did_not_narrow(r1, r3)[1]
                @test !AutoMerge.range_did_not_narrow(r2, r3)[1]
                @test !AutoMerge.range_did_not_narrow(r3, r2)[1]
            end
        end
    end
end
