# helper

function createconnection(name, matrixtype)
	@eval begin
		type $name <: Connection
			w::$matrixtype
			pre::Neuron
			post::Neuron
			prename::Symbol
			postname::Symbol
		end
		export $name
	end
end

function updateconnection!(c::Connection)
end
export updateconnection!

# sparse connections

type SparseConnectionArray
	I::Array{Int64,1}	# post
	J::Array{Int64,1}	# pre
	V::Array{FloatXX,1} # value
	n::Int64
	m::Int64
	nnz::Int64
end
export SparseConnectionArray

import Base.A_mul_B!
function A_mul_B!(α::FloatXX,
				  c::SparseConnectionArray, 
				  v::Array{FloatXX,1},
				  β::FloatXX,
				  res::Array{FloatXX, 1})
	@inbounds for i = 1:c.nnz
		res[c.I[i]] = α * c.V[i] * v[c.J[i]] + β * res[c.I[i]]
	end
	res
end
import Base.*
function *(c::SparseConnectionArray, v::Array{Float64,1})
	res = zeros(c.n)
	@inbounds for i = 1:c.nnz
		res[c.I[i]] += c.V[i] * v[c.J[i]]
	end
	res
end

function sampleconnections(n_ofpre, n_ofpost, nnz)
	c = Tuple[]
	while length(c) < nnz
		sample = (rand(1:n_ofpost), rand(1:n_ofpre))
		if !(sample in c); push!(c, sample); end
	end
	[c[i][1] for i in 1:nnz], [c[i][2] for i in 1:nnz]
end

using Distributions
function createsparseconnection(name)
	createconnection(name, SparseConnectionArray)
	@eval begin
		function $name(pre::Layer, post::Layer; p = .02)
			nnz = rand(Binomial(pre.n_of * post.n_of, p))
			I, J = sampleconnections(pre.n_of, post.n_of, nnz)
			$name(SparseConnectionArray(I, J, randn(FloatXX, nnz)/(10*p*sqrt(pre.n_of)),
										 post.n_of, pre.n_of, nnz),
				  pre.neurons,
				  post.neurons,
				  pre.name,
				  post.name)
		end
	end
end

createsparseconnection(:PlasticSparseConnection)
createsparseconnection(:StaticSparseConnection)

# dense connections
function createdenseconnection(name)
	createconnection(name, Array{FloatXX, 2})
	@eval begin
		function $name(pre::Layer, post::Layer)
			$name(randn(FloatXX, post.n_of, pre.n_of)/(10*sqrt(pre.n_of)),
				  pre.neurons, 
				  post.neurons,
				  pre.name,
				  post.name)
		end
	end
end

createdenseconnection(:PlasticDenseConnection)
createdenseconnection(:StaticDenseConnection)

# One2OneConnection
type IdentityMatrix
end

createconnection(:One2OneConnection, IdentityMatrix)
function One2OneConnection(pre::Layer, post::Layer)
	One2OneConnection(IdentityMatrix(), 
				      pre.neurons, 
					  post.neurons,
					  pre.name,
					  post.name)
end

# TransposeDenseConnection
createconnection(:TransposeDenseConnection, Array{FloatXX, 2})
function TransposeDenseConnection(c::PlasticDenseConnection, net::SimpleNetwork)
	TransposeDenseConnection(c.w, 
						     net.layers[c.postname].neurons,
							 net.layers[c.prename].neurons,
							 c.postname,
							 c.prename)
end

# functions

function weightedprerates!(v::Array{FloatXX, 1}, 
						   con::Dict{Symbol, Connection}, 
						   scale::FloatXX)
	@inbounds for c in values(con)
		weightedprerates!(v, c, scale)
	end
end

function weightedprerates!(v, c::One2OneConnection, scale)
	BLAS.axpy!(scale, c.pre.outp, v);
end

function weightedprerates!(v, c::TransposeDenseConnection, scale)
	BLAS.gemv!('T', scale, c.w, c.pre.outp, FloatXX(1.), v);
end

function weightedprerates!(v, c::Union{PlasticSparseConnection,
									   StaticSparseConnection}, scale)
	A_mul_B!(scale, c.w, c.pre.outp, FloatXX(1.), v);
end

function weightedprerates!(v, c::Union{PlasticDenseConnection,
									   StaticDenseConnection}, scale)
	BLAS.gemv!('N', scale, c.w, c.pre.outp, FloatXX(1.), v);
end
export weightedprerates!

function copyweights!(netfrom::Network, netto::Network)
	for (ln, l) in netto.layers
        for (icn, ic) in l.inputconnections
            for (pren, pre) in ic
                pre.w = deepcopy(netfrom.layers[ln].inputconnections[icn][pren].w)
            end
        end
    end
end
export copyweights!
