# thread_pinning.jl

@info "# THREAD PINNING ##############"

# (option) change thread pinning (default, compact and spread)
using ThreadPinning
using DataFrames
using UnicodePlots

# to use default pinning do nothing, 
@info "THREAD PINNING - default thread pinning"
pinning = "default"


# otherwise:

# uncomment following lines to set compact pinning
# @info "THREAD PINNING - set compact thread pinning"
# ThreadPinning.pinthreads(:compact)

# uncomment following lines to set spread pinning
# @info "THREAD PINNING - set spread thread pinning"
# ThreadPinning.pinthreads(:spread)

@info "THREAD PINNING - threadinfo"
# print(ThreadPinning.threadinfo(; blas=true, hints=true, color=true))
@info ThreadPinning.threadinfo(; blas=true, hints=true, color=true)


# to check: as blas hints might not be supported ThreadPinning with ArmPL

println()

if Threads.nthreads() > 1
    @info "THREAD PINNING - Core 2 core latencies: results"
    # TO DO: ┌ Error: Need at least two Julia threads.")
    latencies = ThreadPinning.bench_core2core_latency();
    @info "latencies" display(latencies)

    @info "THREAD PINNING - Core to core latencies: plot"
    # print(UnicodePlots.heatmap(latencies, colorbar=true, colormap=:jet))

    using Gadfly, Cairo, Fontconfig
    using PDFmerger: append_pdf!
    p = Gadfly.spy(latencies, Guide.Title("Core to core latencies, $pinning pinning"));
    Gadfly.draw(PDF("latencies_$(pinning).pdf"#= , 2048px, 1080px =#), p);
    append_pdf!("plots.pdf", "latencies_$(pinning).pdf", cleanup=true)
else
    return nothing
end
