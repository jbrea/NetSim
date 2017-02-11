using DataStructures

"""
	type SimpleNetwork <: Network
		time::Int64
		layers::DataStructures.OrderedDict{Symbol, Layer}
		plasticconnections::Array{Connection, 1}
		layeriterator::Base.ValueIterator{DataStructures.OrderedDict{Symbol,Simulator.Layer}}
"""

type SimpleNetwork <: Network
	time::Int64
	layers::DataStructures.OrderedDict{Symbol, Layer}
	plasticconnections::Array{Connection, 1}
	# currently iterating a OrderedDict causes memory allocation, see 
	# https://github.com/JuliaLang/DataStructures.jl/issues/93
	# shouldn't be a big deal for this application
	layeriterator::Base.ValueIterator{DataStructures.OrderedDict{Symbol,Layer}}
end

"""
	SimpleNetwork()

Create an empty network
"""
function SimpleNetwork()
	layers = DataStructures.OrderedDict{Symbol, Layer}()
	it = values(layers)
	SimpleNetwork(0, layers, Connection[], it)
end

export SimpleNetwork

import Base.reverse!

function reverse!(d::DataStructures.OrderedDict)
    reverse!(d.keys)
    reverse!(d.vals)
    DataStructures.rehash!(d)
end

"""
	reverselayerorder!(net::SimpleNetwork)

"""
function reverselayerorder!(net::SimpleNetwork)
	reverse!(net.layers)
	net.layeriterator = values(net.layers)
end
export reverselayerorder!

"""
    connect!(net::SimpleNetwork, from::Symbol, to::Symbol, conorkind; label = :default)
"""
function connect!(net::SimpleNetwork, from::Symbol, to::Symbol, conorkind;
				  label = :default)
	contype = connect!(net.layers[from], net.layers[to], conorkind, label = label)
	if ismatch(r"Plastic", contype)
		push!(net.plasticconnections,
		      net.layers[to].inputconnections[label][from])
	end
end

"""
	addlayer!(net::SimpleNetwork, layer::Layer)
"""
function addlayer!(net::SimpleNetwork, layer::Layer)
	net.layers[layer.name] = layer
	net.layeriterator = values(net.layers)
end
export addlayer!

"""
	updatenet!(net::SimpleNetwork)

Call updateneuron! for all layers in `net.layers` 
and updateconnection! for all connections in `net.plasticconnections`
and increment `net.time`.
"""
function updatenet!(net::SimpleNetwork)
	net.time += 1
	for l in net.layeriterator
		collectmessages!(l.neurons, l.inputconnections)
	end
	for l in net.layeriterator
		updateneuron!(l.neurons, l.inputconnections)
	end
	for c in net.plasticconnections
		updateconnection!(c)
	end
end
export updatenet!
