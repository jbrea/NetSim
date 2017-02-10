function monitor(net::Network, variables, n_ofsteps::Int64; 
				 every = 1)
	res = Dict()
	pointers = Dict()
	ranges = Dict()
	for (key, variable, range) in variables
		res[key] = []
		pointers[key] = variable
		ranges[key] = range
	end
	for t in 1:n_ofsteps
		updatenet!(net)
		if t % every == 0
			for (key, value) in res
				push!(value, pointers[key][ranges[key]])
			end
		end
	end
	for (key, value) in res
		res[key] = hcat(value...)'
	end
	res
end
export monitor



