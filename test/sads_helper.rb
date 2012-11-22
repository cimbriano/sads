
def LR_matrix(k, m, q)
	Matrix.build(k, m) { rand q}
end

def column_vector(size)
	column_vector_with_max(size, size)
end

def column_vector_with_max(size, max)
	Matrix.column_vector( Array.new(size) { rand max } )
end

def check_radix_int(radix, x, q)
	# x is a number in Z_q
	#
	# radix is a vector in Z_q with size log q

	# puts "Checking #{radix.reverse} is a radix rep of #{x} mod #{q}"
	acc = 0
	radix.reverse.each_with_index do |r_i, i|
		# puts "#{r_i} * 2 ^ #{i}"
		acc += (r_i * (2 ** i))
	end

	return x == (acc % q)
end

def check_radix_label(label, digest, q)
	# label should be a radix rep of the digest
	chunk_size = Math.log2(q).ceil
	i = 0

	label.each_slice(chunk_size) do |group|

		# puts "Checking chunk: #{group}"
		# puts "Against digest[#{i}] : #{digest[i]}"
		return false unless check_radix_int(group, digest[i], q)
		i+=1

	end
	return true
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

def children_indices(parent)
	[parent + '0', parent + '1']
end

def addSomeElements(sad, num_to_add)
	universe_size = sad.universe_size_m


	num_to_add.times do
		sad.addElement( rand(universe_size) )
	end
end