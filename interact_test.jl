include("abm.jl")
using WebIO, CSSUtil, Interact, Mux
using Agents, DataFrames
using Plots


# default parameters
default_steps = 100

# control
stop_simulation = false
simulation_complete = false

# ui components
html_title = HTML(string("<h3>SIR Model based on the <a href=\"https://juliadynamics.github.io/Agents.jl/stable/examples/sir/\"> Julia Agents.jl implementation</a></h3>"))

# TODO marco or function to generate labelled fields
# steps field
dict_steps_widget = OrderedDict(:steps_label => "Steps", :steps_textbox => textbox("Steps", value=string(default_steps)))
#dict_steps_widget[:steps_textbox] = style(dict_steps_widget[:steps_textbox], Pair(:width, 5em))
steps_widget = Widget{:mywidget}(dict_steps_widget)
@layout! steps_widget hbox(:steps_label, CSSUtil.hskip(1em), :steps_textbox);

start_button = button("Start")
stop_button = button("Stop")
reset_button = button("Reset")
plt = Observable{Any}(plot())


infected(x) = count(i == :I for i in x)
recovered(x) = count(i == :R for i in x)

function test(ob)
    try
        nsteps = parse(Int, steps_widget[:steps_textbox][])
        println("nsteps is $nsteps")
    catch
        for (exc, bt) in Base.catch_stack()
            showerror(stdout, exc, bt)
            println()
        end
    end
end

function simulation_start(ob)

    global stop_simulation = false
    println("starting simulation ...")

    params = COVID.create_params(C=8, max_travel_rate=0.01)
    model = COVID.model_initiation(;params...)
    N = sum(model.Ns) # Total initial population

    to_collect = [(:status, f) for f in (infected, recovered, length)]
    data = init_agent_dataframe(model, to_collect)

    nsteps = parse(Int, steps_widget[:steps_textbox][])

    @async for step in 1:1:nsteps
        try
            if stop_simulation
                stop_simulation = false
                println("stopping simulation")
                break
            else
                sleep(0.001)
                #println("simulation step $step")
                step!(model, COVID.agent_step!)
                collect_agent_data!(data, model, to_collect, step)

                # update plot
                x = data.step
                y_infected = log10.(data[:, Symbol("infected(status)")])
                y_recovered = log10.(data[:, Symbol("recovered(status)")])
                y_dead = log10.(N .- data[:, Symbol("length(status)")])

                p = plot(x, [y_infected, y_recovered, y_dead], label=["infected" "recovered" "dead"])
                xlabel!(p, "steps")
                ylabel!(p, "log( count )")

                if step == nsteps
                    global simulation_complete = true
                    println("simulation complete")
                end

                plt[] = p
            end
        catch
            for (exc, bt) in Base.catch_stack()
                showerror(stdout, exc, bt)
                println()
            end

            global stop_simulation = true
            break
        end
    end
    plt[] = plt[]
end

function simulation_stop(ob)
    global stop_simulation = true
    return plt[]
end

function simulation_reset(ob)
    println("resetting simulation")
    plot()
end

map!(simulation_start, plt, start_button)
map!(simulation_stop, plt, stop_button)
map!(simulation_reset, plt, reset_button)

ui = vbox( # put things one on top of the other
    #node(:div, "hello"),
    html_title,
    steps_widget,
    hbox( # put things one next to the other
        pad(1em, start_button), # to allow some white space around the widget
        pad(1em, stop_button),
        pad(1em, reset_button),
    ),
    plt
);
#display(ui)

# if we are not in Juno IDE then assume webserver environ
if @isdefined(Juno)
    display(ui)
else
    port = 8000
    println("server started on port $port ...")
    fetch(WebIO.webio_serve(page("/", req -> ui), port))
end
