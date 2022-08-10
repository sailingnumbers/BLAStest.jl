# environment.jl

# OPENBLAS_NUM_THREADS=4 BLIS_NUM_THREADS=4 OMP_NUM_THREADS=4 LD_LIBRARY_PATH=/opt/arm/armpl_22.0.2_gcc-11.2/lib /home/ubuntu/julia-1.7.3/bin/julia -t 1

# OPENBLAS_NUM_THREADS=10 BLIS_NUM_THREADS=10 OMP_NUM_THREADS=10 julia -t 1

#module blastest_open_mkl_blis

#greet() = print("Hello World!")

pwd()

#cd("/home/u77446/data/blastest_open_mkl_blis")
#cd("/home/funky/rclonemounts/sn_oracle_coding/dev_2022_05_28_data/data/blastest_open_mkl_blis")
#cd("/home/funky/rclonemounts/sn_coding/dev_2022_05_28_data/data/blastest_open_mkl_blis")

using Pkg
pwd()
readdir()
Pkg.activate(".")
# (You can also use the ] method at the REPL)
# ] activate .
# Note that if you just do Pkg.activate() (no "."), then it activates the base environment. Usually you won't want to activate the base environment if you're trying to set up an environment specific to a certain project folder.
# Pkg.instantiate() # this will install the packages listed in Project.toml

#= using Pkg
Pkg.add(["StatsBase", "BenchmarkTools", "DelimitedFiles", "PDFmerger", "Gadfly", "Cairo", "Fontconfig", "DataFrames", "CSV", "Hwloc", "ThreadPinning", "UnicodePlots", "STREAMBenchmark", "Crayons", "MKL"])
Pkg.add(url="https://github.com/carstenbauer/BandwidthBenchmark.jl")
Pkg.add(url="https://github.com/carstenbauer/BLISBLAS.jl")
Pkg.add("CpuId")
Pkg.add("LoggingExtras")
Pkg.add("SystemBenchmark") =#

using Term, LoggingExtras
global_logger(
    TeeLogger(
        Term.TermLogger(Term.TERM_THEME[]),
        FileLogger("julia.log"),
    ),
);
