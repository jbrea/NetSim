"""
    type Layer
		name::Symbol
		neurons::Neuron
		n_of::Int64
		inputconnections::Dict{Symbol, Dict{Symbol, Connection}}

"""
type Layer
	name::Symbol
	neurons::Neuron
	n_of::Int64
	inputconnections::Dict{Symbol, Dict{Symbol, Connection}}
end
export Layer

"""
    Layer(name::Symbol, neuron::DataType, neuronparams::NeuronParameters, n_of::Int64)

Create an unconnected `Layer` of `n_of` neurons of type `neuron` with parameters
`neuronparams`.
"""
function Layer(name::Symbol, neuron::DataType, 
			   neuronparams::NeuronParameters, n_of::Int64)
	Layer(name, neuron(n_of, neuronparams), n_of, 
	      Dict{Symbol, Dict{Symbol, Connection}}())
end

"""
    connect!(from::Layer, to::Layer, con::Connection; label = :default)

Add to inputconnections of layer `to` the connection `con` with key
[`label`][`from.name`].
"""
function connect!(from::Layer, to::Layer, con::Connection; label = :default)
	if haskey(to.inputconnections, label)
		to.inputconnections[label][from.name] = con
	else
		to.inputconnections[label] = Dict(from.name => con)
	end
	string(typeof(con))
end

"""
    connect!(from::Layer, to::Layer, kind::Union{DataType, Function}; label = :default)

Create connection `kind(from, to)` and add it.
"""
function connect!(from::Layer, to::Layer, kind::Union{DataType, Function}; 
				  label = :default)
	connect!(from, to, kind(from, to), label = label)
end

export connect!
