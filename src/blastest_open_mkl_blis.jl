
@info "# BLAS TEST ####################"

using Statistics, StatsBase, BenchmarkTools
using DelimitedFiles

function get_stats(axpy!, N::Int, T::Type)
    b = @benchmark $(axpy!)(a, x, y) setup=(a=randn($T); x=randn($T, $N); y=randn($T, $N)) evals=1
    GC.gc(true)
    N,
    # b.times, # (to do: save all results, as for now, it prints into columns)
    # gflops(n, t) = 2 * n / t
    minimum(b.times), (2 * N / minimum(b.times)),
    (StatsBase.quantile((b.times), [0.25])), #(StatsBase.quantile((2 * N / (b.times)), [0.25])),
    median(b.times), (2 * N / median(b.times)), 
    mean(b.times), (2 * N / mean(b.times)), 
    (StatsBase.quantile((b.times), [0.75])), #(StatsBase.quantile((2 * N / (b.times)), [0.75])),
    maximum(b.times), (2 * N / maximum(b.times)),
    StatsBase.var(b.times), StatsBase.var(2 * N / (b.times)),
    StatsBase.std(b.times), StatsBase.std(2 * N / (b.times)),
    StatsBase.skewness(b.times), StatsBase.skewness(2 * N / (b.times)),
    StatsBase.kurtosis(b.times), StatsBase.kurtosis(2 * N / (b.times)),
    StatsBase.variation(b.times), StatsBase.variation(2 * N / (b.times)),
    StatsBase.sem(b.times), StatsBase.sem(2 * N / (b.times)),
    StatsBase.mad(b.times), StatsBase.mad(2 * N / (b.times)),
    # StatsBase.zscore(b.times),
    StatsBase.entropy(b.times), StatsBase.entropy(2 * N / (b.times))
end


#= function benchmark(axpy!, T::Type, file_prefix::String)
    open(joinpath(@__DIR__, "$(file_prefix)_$(T).csv"), "w") do file
        println(file, "# length, minimum time seconds, gflops based on minimum time, quantile 025 times, gflops quantile 025, median time seconds, gflops based on median time, mean time seconds, gflops beasd on mean time, quantile 075 times, gflops quantile 075, maximum time seconds, gflops based on maximum time, variance times, gflops variance, standard times deviation, gflops standard deviation, skewness times, gflops skewness, kurtosis times, gflops kurtosis, variation times, gflops variation, standard error of the mean times, gflops standard error of the mean, median absolute deviation times, gflops median absolute deviation, entropy times, times gflops entropy")
        for N in round.(Int, exp10.(0:4))
        #for N in round.(Int, exp10.(0:0.1:8))
         #for N in round.(Int, exp10.(0:7))
            res = get_stats(axpy!, N, T)
            @show res
            println(file, join(res, ','))        
        end
    end
end =#
function benchmark(axpy!, T::Type, file_prefix::String)
    open(joinpath(@__DIR__, "$(file_prefix)_$(T).csv"), "w") do file
        println(file, "# length, minimum time seconds, gflops based on minimum time, quantile 025 times, median time seconds, gflops based on median time, mean time seconds, gflops beasd on mean time, quantile 075 times, maximum time seconds, gflops based on maximum time, variance times, gflops variance, standard deviation times, gflops standard deviation, skewness times, gflops skewness, kurtosis times, gflops kurtosis, variation times, gflops variation, standard error of the mean times, gflops standard error of the mean, median absolute deviation times, gflops median absolute deviation, entropy times, gflops entropy")
        for N in round.(Int, exp10.(0:3))
        #for N in round.(Int, exp10.(0:0.1:8))
         #for N in round.(Int, exp10.(0:7))
            res = get_stats(axpy!, N, T)
            @show res
            println(file, join(res, ','))        
        end
    end
end

function axpy!(a, x, y)
    @simd for i in eachindex(x, y)
        @inbounds y[i] = muladd(a, x[i], y[i])
   end
   return y
end

@info "Julia axpy!"
#= println("
#############################################
### Julia axpy!") =#
for T in (Float16, Float32, Float64)
    benchmark(axpy!, T, "julia")
end


@info "OpenBLAS"
#= println("
#############################################
### OpenBLAS") =#
using LinearAlgebra
@info("BLAS CONFIGURATION => ", BLAS.get_config())
@info("Current # of BLAS threads => ", BLAS.get_num_threads())
@info("Current # of Julia threads => ", Threads.nthreads())

for T in (Float16, Float32, Float64)
    benchmark(BLAS.axpy!, T, "open")
end


@info "BLISBLAS"
#= println("
#############################################
### BLISBLAS") =#
using BLISBLAS
@info("BLAS CONFIGURATION => ", BLAS.get_config())
@info("Current # of BLAS threads => ", BLAS.get_num_threads())
@info("Current # of Julia threads => ", Threads.nthreads())
using LinearAlgebra
for T in (Float16, Float32, Float64)
    benchmark(BLAS.axpy!, T, "blis")
end


if Base.Sys.ARCH === :aarch64 # only :aarch64
    #println("
    #############################################
    ### ArmPL")
    @info "ArmPL"
    using ArmPL
    @info("BLAS CONFIGURATION => ArmPL")
    @info("Current # of Julia threads => ", Threads.nthreads())
    using LinearAlgebra
    for T in (Float16, Float32, Float64)
        benchmark(BLAS.axpy!, T, "armpl")
    end
elseif Base.Sys.ARCH === :x86_64 # only x86
    @info "MKL"
    #= println("
    #############################################
    ### MKL") =#
    using MKL
    @info("BLAS CONFIGURATION => ", BLAS.get_config())
    @info("Current # of BLAS threads => ", BLAS.get_num_threads())
    @info("Current # of Julia threads => ", Threads.nthreads())
    using LinearAlgebra
    for T in (Float16, Float32, Float64)
        benchmark(BLAS.axpy!, T, "mkl")
    end
end


### DataFrames
using DataFrames
using CSV
#=                         function load_df(julia, open, blis, armpl)
                                global julia = DataFrame(CSV.File("$julia.csv", normalizenames = true))
                                global open = DataFrame(CSV.File("$open.csv", normalizenames = true))
                                global blis = DataFrame(CSV.File("$blis.csv", normalizenames = true))
                                global armpl = DataFrame(CSV.File("$armpl.csv", normalizenames = true))
                        end

                        load_df(julia_Float16, open_Float16, blis_Float16, armpl_Float16) 
                        julia_times_16_df, open_times_16_df, blis_times_16_df =#

julia_times_16_df = DataFrame(CSV.File("julia_Float16.csv", normalizenames = true))
open_times_16_df = DataFrame(CSV.File("open_Float16.csv", normalizenames = true))
blis_times_16_df = DataFrame(CSV.File("blis_Float16.csv", normalizenames = true))
if Base.Sys.ARCH === :aarch64 # only :aarch64
    armpl_times_16_df = DataFrame(CSV.File("armpl_Float16.csv", normalizenames = true))
elseif Base.Sys.ARCH === :x86_64 # only x86
    mkl_times_16_df = DataFrame(CSV.File("mkl_Float16.csv", normalizenames = true))
end

julia_times_32_df = DataFrame(CSV.File("julia_Float32.csv", normalizenames = true))
open_times_32_df = DataFrame(CSV.File("open_Float32.csv", normalizenames = true))
blis_times_32_df = DataFrame(CSV.File("blis_Float32.csv", normalizenames = true))
if Base.Sys.ARCH === :aarch64 # only :aarch64
    armpl_times_32_df = DataFrame(CSV.File("armpl_Float32.csv", normalizenames = true))
elseif Base.Sys.ARCH === :x86_64 # only x86
    mkl_times_32_df = DataFrame(CSV.File("mkl_Float32.csv", normalizenames = true))
end

julia_times_64_df = DataFrame(CSV.File("julia_Float64.csv", normalizenames = true))
open_times_64_df = DataFrame(CSV.File("open_Float64.csv", normalizenames = true))
blis_times_64_df = DataFrame(CSV.File("blis_Float64.csv", normalizenames = true))
if Base.Sys.ARCH === :aarch64 # only aarch64
    armpl_times_64_df = DataFrame(CSV.File("armpl_Float64.csv", normalizenames = true))
elseif Base.Sys.ARCH === :x86_64 # only x86
    mkl_times_64_df = DataFrame(CSV.File("mkl_Float64.csv", normalizenames = true))
end

# dziala
#= stats_col = "minimum_time_seconds_", "gflops_based_on_minimum_time_", "quantile_025_", "median_time_seconds_", "gflops_based_on_median_time_", "mean_time_seconds_", "gflops_beasd_on_mean_time_", "quantile_075_", "maximum_time_seconds_", "gflops_based_on_maximum_time_", "variance", "standard_deviation", "skewness", "kurtosis", "variation", "sem", "med", "entropy"
 =#
@info "Making charts for the following statistics:" 
stats_col = "minimum_time_seconds", "gflops_based_on_minimum_time", "quantile_025_times", "median_time_seconds", "gflops_based_on_median_time", "mean_time_seconds", "gflops_beasd_on_mean_time", "quantile_075_times", "maximum_time_seconds", "gflops_based_on_maximum_time", "variance_times", "gflops_variance", "standard_deviation_times", "gflops_standard_deviation", "skewness_times", "gflops_skewness", "kurtosis_times", "gflops_kurtosis", "variation_times", "gflops_variation", "standard_error_of_the_mean_times", "gflops_standard_error_of_the_mean", "median_absolute_deviation_times", "gflops_median_absolute_deviation", "entropy_times", "gflops_entropy"


# works
using Gadfly, Cairo, Fontconfig
# Gadfly.set_default_plot_size(21cm ,8cm)
Gadfly.set_default_plot_size(1650px, 1200px)
#Gadfly.push_theme(:default) 
Gadfly.push_theme(:dark)
using PDFmerger: append_pdf!
if Base.Sys.ARCH === :aarch64 # only aarch64
    function gadflyplot(title, julia, open, blis, armpl)
        for s in stats_col
            p = Gadfly.plot(
                layer( x = (julia[!, :_length]), y = (julia[!, s]),
                            #color = [colorant"red1"],
                            color=["Julia"], Geom.line, Geom.point,
                            #Geom.smooth(method = :loess, smoothing = 0.8)                    
                            ),
                layer( x = (open[!, :_length]), y = (open[!, s]),
                            #color = [colorant"green1"],
                            color=["OpenBLAS"], Geom.line, Geom.point,
                            #Geom.smooth(method = :loess, smoothing = 0.8)
                            ),
                layer( x = (blis[!, :_length]), y = (blis[!, s]),
                            #color = [colorant"yellow1"],
                            color=["BLISBLAS"], Geom.line, Geom.point,
                            #Geom.smooth(method = :loess, smoothing = 0.8)
                        ),
                layer( x = (armpl[!, :_length]), y = (armpl[!, s]),
                            #color = [colorant"blue1"],
                            color=["ArmPL"], Geom.line, Geom.point,
                            #Geom.smooth(method = :loess, smoothing = 0.8)
                            ),
#=                 layer( x = (mkl[!, :_length]), y = (armpl[!, s]),
                            #color = [colorant"blue1"],
                            color=["MKL"], Geom.line, Geom.point,
                #Geom.smooth(method = :loess, smoothing = 0.8)
                ),  =#                
            Guide.XLabel("N (vector size) [log10]"),
            Guide.YLabel("$s", orientation=:vertical),
            Guide.Title("$title.$s"),
            Scale.x_log10,
            # Scale.y_log10,
            Guide.colorkey(title=""),
            # Guide.manual_color_key("Shape", ["Average", "Control"], ["white", "ivory"]), # manual legend # pewnie bedzie dzialac jesli coloranty
            #Scale.color_discrete,
            #Guide.colorkey(title = "blases"),
            )
            #Gadfly.draw(PDF("temp.pdf"#= , 2048px, 1080px =#), p)
            #append_pdf!("allplots.pdf", "temp.pdf", cleanup=true)
            Gadfly.draw(PDF("$title.$s.pdf"#= , 2048px, 1080px =#), p)
        #=  PDFmerger. =#append_pdf!("plots.pdf", "$title.$s.pdf", cleanup=true)
        end
    end
elseif Base.Sys.ARCH === :x86_64 # only x86  
    function gadflyplot(title, julia, open, blis, mkl)
        for s in stats_col
            p = Gadfly.plot(
                layer( x = (julia[!, :_length]), y = (julia[!, s]),
                            #color = [colorant"red1"],
                            color=["Julia"], Geom.line, Geom.point,
                            #Geom.smooth(method = :loess, smoothing = 0.8)                    
                            ),
                layer( x = (open[!, :_length]), y = (open[!, s]),
                            #color = [colorant"green1"],
                            color=["OpenBLAS"], Geom.line, Geom.point,
                            #Geom.smooth(method = :loess, smoothing = 0.8)
                            ),
                layer( x = (blis[!, :_length]), y = (blis[!, s]),
                            #color = [colorant"yellow1"],
                            color=["BLISBLAS"], Geom.line, Geom.point,
                            #Geom.smooth(method = :loess, smoothing = 0.8)
                        ),#= 
                layer( x = (armpl[!, :_length]), y = (armpl[!, s]),
                            #color = [colorant"blue1"],
                            color=["ArmPL"], Geom.line, Geom.point,
                            #Geom.smooth(method = :loess, smoothing = 0.8)
                            ), =#
                layer( x = (mkl[!, :_length]), y = (mkl[!, s]),
                            #color = [colorant"blue1"],
                            color=["MKL"], Geom.line, Geom.point,
                #Geom.smooth(method = :loess, smoothing = 0.8)
                ),                 
            Guide.XLabel("N (vector size) [log10]"),
            Guide.YLabel("$s", orientation=:vertical),
            Guide.Title("$title.$s"),
            Scale.x_log10,
            # Scale.y_log10,
            Guide.colorkey(title=""),
            # Guide.manual_color_key("Shape", ["Average", "Control"], ["white", "ivory"]), # manual legend # pewnie bedzie dzialac jesli coloranty
            #Scale.color_discrete,
            #Guide.colorkey(title = "blases"),
            )
            #Gadfly.draw(PDF("temp.pdf"#= , 2048px, 1080px =#), p)
            #append_pdf!("allplots.pdf", "temp.pdf", cleanup=true)
            Gadfly.draw(PDF("$title.$s.pdf"#= , 2048px, 1080px =#), p)
        #=  PDFmerger. =#append_pdf!("plots.pdf", "$title.$s.pdf", cleanup=true)
        end
    end
end

@info "Saving charts. Output is <plots.pdf> file."
if Base.Sys.ARCH === :aarch64 # only aarch64
    gadflyplot("Float16", julia_times_16_df, open_times_16_df, blis_times_16_df, armpl_times_16_df)
    gadflyplot("Float32", julia_times_32_df, open_times_32_df, blis_times_32_df, armpl_times_32_df)
    gadflyplot("Float64", julia_times_64_df, open_times_64_df, blis_times_64_df, armpl_times_64_df)
elseif Base.Sys.ARCH === :x86_64 # only x86
    gadflyplot("Float16", julia_times_16_df, open_times_16_df, blis_times_16_df, mkl_times_16_df)
    gadflyplot("Float32", julia_times_32_df, open_times_32_df, blis_times_32_df, mkl_times_32_df)
    gadflyplot("Float64", julia_times_64_df, open_times_64_df, blis_times_64_df, mkl_times_64_df)
end

#= println("
#############################################
### Blas test results were saved to csv files")

println("
#############################################
### BLAS TEST charts were saved to plots.pdf file") =#

#end # module
