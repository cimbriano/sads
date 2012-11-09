
def LR_matrix(k, m, q)
	Matrix.build(k, m) { rand q}
end

def column_vector(size)
	Matrix.column_vector( (0...size).to_a )
end

def check_radix_int(radix, x, q)
	# x is a number in Z_q
	#
	# radix is a vector in Z_q with size log q
	i = 0
	radix.inject(0) do |result , r_i|
		result + ((r_i * 2 ** i) % q)

		i+=1
	end
end

def check_radix_label(label, digest, q)
	# label should be a radix rep of the digest

	chunk_size = Math.log2(q) + 1
	i = 0

	label.each_slice(chunk_size) do |group|
		return false unless check_radix_int(group, digest[i], q)
		i+=1
	end
	return true
end