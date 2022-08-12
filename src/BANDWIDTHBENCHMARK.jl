@info "# BANDWIDTHBENCHMARKS ################"

using BandwidthBenchmark # [as of 08 2022 not registered: add https://github.com/carstenbauer/BandwidthBenchmark.jl]
using DataFrames
using UnicodePlots

@info "BANDWIDTHBENCHMARK - memory bandwidth using streaming kernels"
bwbench(; verbose=true);
BandwidthBenchmark.bwbench(#= ; verbose=true =#)

print(BandwidthBenchmark.bwbench(#= ; verbose=true =#))
@info BandwidthBenchmark.bwbench(#= ; verbose=true =#)
@info "clear GC", GC.gc();

@info "Some variables"  BandwidthBenchmark.bwbench(; verbose=true)

println("
# BANDWIDTHBENCHMARK - memory bandwidth - increasing number of threads")
df = DataFrame(BandwidthBenchmark.bwscaling(#= ; verbose=true =#), :auto)
print(UnicodePlots.lineplot(df[!,:x1], df[!,:x2], title = "Memory bandwidth (bwscaling) - (1:max_nthreads) [lineplot])", xlabel = "# of cores", ylabel = "MFlops/s", border=:dotted))
println()
print(UnicodePlots.barplot(
        df[!,:x1], 
        df[!,:x2],
        title = "Memory bandwidth (bwscaling) - (1:max_nthreads) [barplot]"
        ))
@info "clear GC", GC.gc();

println("
# BANDWIDTHBENCHMARK - floating point performance - increasing number of threads
# (triad kernel based scaling)")
df = DataFrame(BandwidthBenchmark.flopsscaling(), :auto)
print(UnicodePlots.lineplot(
        df[!,:x1], df[!,:x2], 
        title = "Floating point performance (flopsscaling) - increasing number of threads [lineplot]", 
        xlabel = "# of cores", ylabel = "MFlops/s", 
        border=:dotted))
println()
print(UnicodePlots.barplot(
        df[!,:x1], 
        df[!,:x2],
        title = "Floating point performance (flopsscaling) - increasing number of threads  [barplot]"
        ))
@info "clear GC", GC.gc();


