
def LR_matrix(k, m, q)
	Matrix.build(k, m) { rand q}
end

def column_vector(size)
	column_vector_with_max(size, size)
end

def column_vector_with_max(size, max)
	Vector.elements( Array.new(size) { rand max } )
end

def set_of_all_node_indices(sad)
	num_layers = Math.log2(sad.universe_size_m).ceil
	layers = Array.new

	layers << ['0']
	# puts "layers: #{layers}"
	num_layers.times do
		i_th_layer = []

		layers.last.each do |parent|
				i_th_layer << children_indices(parent)
				# puts "layers: #{layers}"
		end

		layers << i_th_layer.flatten
	end

	return layers.flatten
end

def set_of_leaf_indices(prover)
	set_of_all_node_indices(prover).reject { |n| n.length != prover.bits_needed_for_leaves}
end

def children_indices(parent)
	[parent + '0', parent + '1']
end

def addSomeElements(prover, num_to_add)
	universe_size = prover.universe_size_m

	num_to_add.times do
		prover.addElement( rand(universe_size) )
	end
end

