
def LR_matrix(k, m, q)
	Matrix.build(k, m) { rand q}
end

def column_vector(size)
	column_vector_with_max(size, size)
end

def column_vector_with_max(size, max)
	Vector.elements( Array.new(size) { rand max } )
end

def set_of_all_node_indices(universe_size)
	num_layers = Math.log2(universe_size).ceil
	layers = Array.new

	layers << ['0']

	num_layers.times do
		layers.last.each do |parent|
				layers << children_indices(parent)
		end
	end

	return layers.flatten
end

def set_of_leaf_indices(universe_size, bits_needed_for_leaves)
	set_of_all_node_indices(universe_size).reject { |n| n.length != bits_needed_for_leaves}
end

def children_indices(parent)
	[parent + '0', parent + '1']
end

def addSomeElements(sad, num_to_add)
	universe_size = sad.universe_size_m


	num_to_add.times do
		sad.addElement( rand(universe_size) )
	end
end

def parent(index)
	index[0...-1] unless index.length == 1
end