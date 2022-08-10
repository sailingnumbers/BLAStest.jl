
# # install packages
# using Pkg
#   Pkg.add("BenchmarkTools")
#   Pkg.add("Hwloc")
#   Pkg.add("ThreadPinning")
#   Pkg.add("DataFrames")
#   Pkg.add("UnicodePlots")
#   Pkg.add("STREAMBenchmark")
#   Pkg.add(url="https://github.com/carstenbauer/BandwidthBenchmark.jl")
#   Pkg.add("Crayons")

using Pkg
Pkg.activate(".")
include("environment.jl")

include("machine.jl")
include("versions.jl")

include("thread_pinning.jl")

include("STREAMBenchmarks.jl")
include("BANDWIDTHBENCHMARK.jl")
include("blastest_open_mkl_blis.jl")

# include("")
