# NetSim
A framework for fast prototyping of (rate-based and spiking neural) networks.

## Installation

```
Pkg.clone("https://github.com/jbrea/NetSim")
```

## Example

```
using NetSim

type NoNeuronParameters <: NeuronParameters
end

type InputNeuron <: Neuron
	outp::Array{Float64, 1}
end
function InputNeuron(n_of::Int64, parameters::NoNeuronParameters)
	InputNeuron(rand(n_of))
end

type MyNeuronParameters <: NeuronParameters
	gamma::Float64
end

type MyNeuron <: Neuron
	parameters::MyNeuronParameters
	membranePotential::Array{Float64, 1}
	outp::Array{Float64, 1}
end
function MyNeuron(n_of::Int64, parameters::MyNeuronParameters)
	MyNeuron(parameters, zeros(n_of), zeros(n_of))
end
import NetSim.updateneuron!
function updateneuron!(neuron::MyNeuron)
	for i in 1:length(neuron.outp)
		neuron.membranePotential[i] *= neuron.parameters.gamma
		neuron.outp[i] = clamp(neuron.membranePotential[i], 0, 1)
	end
end
import NetSim.collectmessages!
function collectmessages!(neuron::MyNeuron, inputconnections)
	weightedprerates!(neuron.membranePotential, 
					  inputconnections[:default],
					  1 - neuron.parameters.gamma)
end

net = SimpleNetwork()
addlayer!(net, Layer(:inputlayer, InputNeuron, NoNeuronParameters(), 5))
addlayer!(net, Layer(:firstlayer, MyNeuron, MyNeuronParameters(.8), 5))
connect!(net, :inputlayer, :firstlayer, One2OneConnection)
connect!(net, :firstlayer, :firstlayer, StaticDenseConnection)

# visualizenet(net)

recordedvariables =
	[("potential", net.layers[:firstlayer].neurons.membranePotential, 1);
	 ("outp", net.layers[:firstlayer].neurons.outp, 1);
	 ("inp", net.layers[:inputlayer].neurons.outp, 1:5)]

net.layers[:firstlayer].neurons.membranePotential[:] = -rand(5)
data = monitor(net, recordedvariables, 10^2)

using PyPlot
plot(data["potential"], label = "potential of neuron 1")
plot(data["outp"], label = "output of neuron 1")
plot(data["inp"][:, 1], label = "input")
plt[:legend]()
```



