# logging.yaml
# Moje lekkie zmiany ktore DZIALAJA
# na podstawie: 
# https://discourse.julialang.org/t/how-to-save-logging-output-to-a-log-file/14004/6
# i 
# https://discourse.julialang.org/t/how-to-save-logging-output-to-a-log-file/14004/6

# WORKS / LOGGING TO THE FILE (ONLY), ALSO LOGGING OF FUNCTIONS THAT RETURN NOTHING
# Load the logging module
using Logging

# Open a textfile for writing
io = open("log.txt", "w+")
io = open("log.txt", "a") # append

# Create a simple logger
logger = SimpleLogger(io)
# logger = ConsoleLogger(io)

# check current logger
logger = current_logger()

with_logger(logger) do
    @info("a context specific log message")
    @info "a", Base.Sys.cpu_summary(io) # works
end

# OR SET A GLOBAL_LOGGER

# https://docs.julialang.org/en/v1/stdlib/Logging/#Logging.global_logger
# Set the global logger to logger
global_logger(logger)

# EXAMPLE: This message will now also be written to the file
@info("global log message")
@info "Sys.CPU_NAME" Sys.CPU_NAME
@info Sys.islinux()
@info Base.Sys.cpu_summary(; io)

# EXAMLE (NOTHING): This way to output Pkg.status()
Pkg.status(; io) # more info is in julia "? Pkg.status"
# To tez dziala ale nie pokazuje w REPL i na koncu wyswietla "nothing"
@info Pkg.status(; io)

# EXAMPLE: Another example with text and code to execute
using BandwidthBenchmark
@info "Some variables"  BandwidthBenchmark.bwbench(; verbose=true)

# EXAMPLE / WORKS
@info versioninfo(io, verbose=true)
# ale to juz nie, return nothing
using InteractiveUtils
@info InteractiveUtils.versioninfo(io; verbose=true)

# Flush or close the file - THIS IS REQUIRED TO WRITE IO TO THE FILE
flush(io)
# or
close(io)







# VERSION 1: (NOT FORMATED) SEND MESSAGES TO MULTIPLE LOCATIONS
# https://julialogging.github.io/how-to/tee/
# ale cos nie dziala
using Logging, LoggingExtras
logger = TeeLogger(
    global_logger(),          # Current global logger (stderr)
    FileLogger("logfile.log") # FileLogger writing to logfile.log
)

@info "Sys.cpu_summary()", Base.Sys.cpu_summary()

close(io)







# DZIALA z Sys.cpu_summary()" ale z Pkg.status() chyba nie dziala
using Logging, LoggingExtras
logger = TeeLogger(
    # current_logger(),
    global_logger(),          # Current global logger (stderr)
    FileLogger("logfile.log") # FileLogger writing to logfile.log
)

with_logger(logger) do
    @info "asdfdswe"
    println("Asd")
    @info "a", Base.Sys.cpu_summary()
    @info "gfg"
    @info "1232Asddsaqweqweewq"
end









# FormatLogger (Sink)
# The FormatLogger is a sink that formats the message and prints to a wrapped IO. Formatting is done by providing a function f(io::IO, log_args::NamedTuple).
# FormatLogger can take as its second argument either a writeable IO or a filepath. The append::Bool keyword argument determines whether the file is opened in append mode ("a") or truncate mode ("w").
using LoggingExtras

logger = FormatLogger() do io, args
           println(io, args._module, " | ", "[", args.level, "] ", args.message)
       end;

logger = FormatLogger("out.log"; append=true) do io, args
            println(io, args._module, " | ", "[", args.level, "] ", args.message)
        end;

with_logger(logger) do
           @info "This is an informational message."
           @warn "This is a warning, should take a look."
       end






# DZIALA - wysylanie formatowanych logow do pliku i do terminala ale nothing nie wysyla
using Logging, LoggingExtras
logger = TeeLogger(
    FormatLogger() do io, args
        println(io, args._module, " | ", "[", args.level, "] ", args.message)
    end,
    FormatLogger("out.log"; append=true) do io, args
        println(io, args._module, " | ", "[", args.level, "] ", args.message)
    end,
)

using Pkg
with_logger(logger) do
    @info "asdfdswe"
    println("Asd")
    @info "a", Base.Sys.cpu_summary()
    @info "gfg"
    @info "1232Asddsaqweqweewq"
    @info Pkg.status()
end 










function l()
if x == isnothing == true
io = open("out.log", "a") # append
# Create a simple logger
logger = SimpleLogger(io)
# logger = ConsoleLogger(io)
else
logger = TeeLogger(
    FormatLogger() do io, args
        println(io, args._module, " | ", "[", args.level, "] ", args.message)
    end,
    FormatLogger("out.log"; append=true) do io, args
        println(io, args._module, " | ", "[", args.level, "] ", args.message)
    end,
)
end
end

using Pkg

with_logger(l()) do
    @info "asdfdswe"
    println("Asd")
    @info "a", Base.Sys.cpu_summary()
    @info "gfg"
    @info "1232Asddsaqweqweewq"
end 

with_logger(l()) do
    @info "asdfdswe"
    println("Asd")
    @info "a", Base.Sys.cpu_summary()
    @info "gfg"
    @info "1232Asddsaqweqweewq"
    x
end 

x = @info Base.Sys.cpu_summary()