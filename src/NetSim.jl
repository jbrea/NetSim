__precompile__()
module NetSim

if !isdefined(Main, :FloatXX)
	const FloatXX = Float64
else
	const FloatXX = Main.FloatXX
end
#print_with_color(:blue, "Simulator.FloatXX = $FloatXX\n")

abstract Network
export Network
abstract Connection
export Connection
abstract Neuron
export Neuron
abstract NeuronParameters
export NeuronParameters
include("layers.jl")
include("networks.jl")
include("connections.jl")
include("visualize.jl")

end
