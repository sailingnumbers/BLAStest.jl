# versions.jl

@info ("# SOFTWARE VERSIONS #################")

using InteractiveUtils
@info "Julia version"
str = sprint(io -> InteractiveUtils.versioninfo(io; verbose=true));
@info str

using Pkg
@info "Package version"
str = sprint(io -> Pkg.status(; io = io));
@info str
