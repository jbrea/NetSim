include("equilibriumprop.jl")
using Base.Test

# linear feedfoward network

function setinputandweights!(net, inp, w1, w2; inputlayer = :firstlayer)
	net.layers[inputlayer].neurons.outp:] = inp
	net.layers[:hiddenlayer1].inputconnections[:default][:firstlayer].w[:] = w1
	net.layers[:outputlayer].inputconnections[:default][:hiddenlayer1].w[:] = w2
	net.layers[:biaslayer].neurons.outp:] = [0.]
end

nin = 5
nh = 4
nout = 3

w1 = randn(nh, nin)/(2 * nin)
w2 = randn(nout, nh)/(2 * nh)
inp = rand(nin)

net = SimpleNetwork()
getlayersdeepnet!(net, [nin; nh; nout], 
				 neurontype = LinearRateNeuron,
				 neuronparams = NoNeuronParameters(),
				 neurontypeoutput = LinearRateNeuron,
				 neuronparamsoutput = NoNeuronParameters())
connectforward!(net, 1)
setinputandweights!(net, inp, w1, w2)

updatenet!(net)

@test_approx_eq(net.layers[:outputlayer].neurons.outp
				w2 * w1 * inp)

# relu feedforward network

net = SimpleNetwork()
getlayersdeepnet!(net, [nin; nh; nout])
connectforward!(net, 1)
setinputandweights!(net, inp, w1, w2)
updatenet!(net)

@test_approx_eq(net.layers[:outputlayer].neurons.outp 
				max(0, w2 * max(0, w1 * max(0, inp))))

# linear, symmetric recurrent network

net = getequipropnet([nin; nh; nout], 
				 neurontype = LinearLeakyRateNeuron,
				 neurontypeoutput = LinearLeakyRateNeuron,
				 symmetrize = true)
setinputandweights!(net, inp, w1, w2; inputlayer = :inputlayer)
for _ in 1:10^2; updatenet!(net); end

@test_approx_eq(net.layers[:hiddenlayer1].neurons.outp
				inv(eye(nh) - w2' * w2) * w1 * inp)

