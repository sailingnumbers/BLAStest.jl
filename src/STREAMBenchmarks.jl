@info "# STREAMBenchmarks ###########"

using STREAMBenchmark

@info "STREAMBenchmark - single and multithreaded memory bandwidth"
# STREAMBenchmark.benchmark()
sbench = STREAMBenchmark.benchmark()
@info "STREAMBenchmark - single-threaded memory bandwidth MB/s - copy, scale, add, triad" sbench.single
@info "STREAMBenchmark - multi-threaded memory bandwidth MB/s - copy, scale, add, triad" sbench.multi



@info "STREAMBenchmark - memory bandwidth scalling with number of threads"
sbench_scale = STREAMBenchmark.scaling_benchmark()
@info "STREAMBenchmark - memory bandwith in MB/S for increasing number of threads: ", sbench_scale
#= print(UnicodePlots.lineplot(1:length(sbench_scale), sbench_scale, title = "Bandwidth Scaling", xlabel = "# cores", ylabel = "MB/s", border = :dotted#= , canvas = AsciiCanvas =#)) =#

using Gadfly, Cairo, Fontconfig
p = Gadfly.plot(y = sbench_scale, Geom.line, Geom.point, 
                Guide.xticks(ticks=[1:Threads.nthreads();]),
                Guide.Title("Bandwidth Scaling, $pinning pinning"))
Gadfly.draw(PDF("Bandwidth_Scaling_$(pinning).pdf"#= , 2048px, 1080px =#), p);
append_pdf!("plots.pdf", "Bandwidth_Scaling_$(pinning).pdf", cleanup=true)


# @info "GC.gc()" GC.gc() # clear gc

@info "STREAMBenchmark - vector lengths check (default is four times the size of the outermost cache)" STREAMBenchmark.vector_length_dependence()