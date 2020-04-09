# An Interactive COVID-19 Model in Julia

A proof of concept for using Julia to run interactive simulations in a web environment

This is a direct port of the [covid19 example](https://juliadynamics.github.io/Agents.jl/stable/examples/sir/) in Agents.jl into a web controllable version using Interact.jl

## Install

[Download and install Julia](https://julialang.org/downloads/platform/)

On Linux you may also need to install `libqt5widgets5`

Start a Julia REPL with:
```
julia
```
then use the `]` to enter into the package management console
```
julia>]
(@1.4) pkg>
```
now install `Agents.jl` from the `master` branch. 
```
(@v1.4) pkg> add https://github.com/JuliaDynamics/Agents.jl.git
```

This is requried to run the covid19 example code which uses features not available in the stable version. The code changes day to day so be sure to update the package and/or code if you have issues.

If you want to use the graph plots in their example, you will also need to install `AgentsPlots.jl` from the corresponding repo

Install remaining dependencies
```
(@v1.4) pkg> add CSSUtil WebIO Interact Mux Plots DataFrames DrWatson LightGraphs Distributions
```

## Run

Start the server
```
sudo julia interact_test.jl
```
It can take a long time to start initially as Julia needs to complie libraries etc. Once you see `started server on port 8000`, go to `localhost:8000`. Press start to begin the simulation, it may take about 10 seconds to start intially.

## Develop

Use the Juno IDE. Interact.jl can also output to an Electron window or an IJulia notebook.

To iterate quickly using the Juno IDE, use the built in REPL to include the code:
```
julia> include("interact_test.jl")
```
This will display the UI in the Plots tab. To make changes, edit the code and reinclude via the REPL command above. You can stop and start the Julia REPL to clear the workspace if needed.