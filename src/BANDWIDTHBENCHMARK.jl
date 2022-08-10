@info "# BANDWIDTHBENCHMARKS ################"

using BandwidthBenchmark
using DataFrames
using UnicodePlots

println("
# BANDWIDTHBENCHMARK - memory bandwidth using streaming kernels")
print(BandwidthBenchmark.bwbench(#= ; verbose=true =#))
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


