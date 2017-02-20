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
"""
	abstract Connection
	
Connections have fields (see `createconnection` in connections.jl)
	* `w`			parameters
	* `pre`			pointer to neurons of pre layer
	* `post`		pointer to neurons of post layer
	* `prename`		name of pre layer
	* `postname`	name of post layer

PlasticSparseConnection <: Connection
StaticSparseConnection <: Connection
PlasticDenseConnection <: Connection
StaticDenseConnection <: Connection
One2OneConnection <: Connection
TransposeDenseConnection <: Connection
"""
abstract Connection
export Connection
"""
	abstract Neuron

Neurons should at least have field `outp` (used by `weightedprerates`).
"""
abstract Neuron
export Neuron
abstract NeuronParameters
export NeuronParameters
include("layers.jl")
include("networks.jl")
include("connections.jl")
include("neurons.jl")
include("monitor.jl")
include("visualize.jl")

end
