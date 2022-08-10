# machine.jl

@info ("# MACHINE SPECS ####################")

@info "Julia Base Machine Info" (Base.Sys.cpu_summary()) (Sys.CPU_NAME) (Sys.MACHINE) (Sys.ARCH) (Sys.CPU_THREADS) (Threads.nthreads()) (Sys.total_memory()/2^20) (Sys.free_memory()/2^20) (Sys.loadavg()) (Sys.SC_CLK_TCK)

using Hwloc
@info "Hwloc Machine Info" (num_physical_cores()) (num_virtual_cores()) (num_numa_nodes()) (num_packages()) ("Cache size in Bytes: ", Hwloc.cachesize()) (Hwloc.cachelinesize())
@info "Basic topology (only stdout):" Hwloc.topology_info()
@info "Detailed topology (only stdout):" Hwloc.topology()

# only x86
if Base.Sys.ARCH === :x86_64
    using CpuId
    @info "CpuId Machine Info" (cpuinfo())
    @info "CpuId Machine Info" (cpucores()) (cputhreads()) (CpuId.cpunodes()) (CpuId.cpucores_total())
    @info "CpuId Feature Table" 
    @info (cpufeaturetable())
else
    return nothing
end

@info "SystemBenchmark / Results will be saved to log and machine_systembenchmark.txt file"
using SystemBenchmark
function sysbenchmachine()
    res = runbenchmark();
    @info (res, allrows=true, allcols=true)
    # Save to disk (includes a system report)
    savebenchmark(joinpath(@__DIR__, "machine_systembenchmark.txt"), res)
end
sysbenchmachine()

