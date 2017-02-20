#using GraphViz

function getgraph(net::Network)
	g = "digraph network {"
	for (ln, l) in net.layers
		for (icn, ic) in l.inputconnections
			for (pren, pre) in ic
				name = match(r"\.(.*)", string(typeof(pre))).captures[1]
				g *= "$pren -> $ln [xlabel = \"$icn.$name\"];"
			end
		end
	end
	g * "}"
end

function visualizenet(net::Network)
	g = getgraph(net)
	try
		run(pipeline(`echo $g`, `dot -Tx11`))
	catch
		warn("Is graphviz installed and in the search path?")
		println("The graph to be plotted is:\n $g")
	end
	#GraphViz.layout!(g, engine = "dot"); GraphViz.render_x11(GraphViz.Context(), g)
end
export visualizenet
