using Term

rend = RenderableText("""
{bold red}Woah, my first {yellow italic}`Renderable`!
""")
print(rend)

import Term: install_term_logger
install_term_logger()
io = open("log.txt", "a") # append
@info print(io, rend)
flush(io)



import Term: Panel

print(Panel("this is {red}RED{/red}"; fit=true))
print(IO, Panel("this is {red}RED{/red}"; fit=true))
@info (Panel("this is {red}RED{/red}"; fit=true))

print(Panel(Base.Sys.cpu_summary(); fit=true)) # MethodError: no method matching vstack(::Nothing)
print(Panel("as", Threads.nthreads(); fit=true))

using Term: TextBox
TextBox("A very long piece of text"^100; title="TEXT", width=80, fit=false)

import Term: Panel
import Term.Layout: Spacer
import Term.Layout: vLine
space = Spacer(10, 5)
vLine(10; style="red") * space * vLine(10; style="blue") * space * vLine(10; style="green", box=:DOUBLE)

vLine((10; style="red"), TextBox("A very long piece of text"))



# https://discourse.julialang.org/t/term-jl-logging-sending-messages-to-multiple-locations/84841
using Term, LoggingExtras

global_logger(
           TeeLogger(
               Term.TermLogger(Term.TERM_THEME[]),
               FileLogger("julia.log"),
           ),
       );

@info "hello info"

@warn "hello warn"

@info Base.Sys.cpu_summary()

using Pkg
@info Pkg.status()

# works
# https://discourse.julialang.org/t/term-jl-logging-sending-messages-to-multiple-locations/84841/3
# Not directly, because those functions don’t use the logging system, they simply print to stdout. You can of course create the string and log that:
julia> using Pkg
julia> str = sprint(io -> Pkg.status(; io = io));

