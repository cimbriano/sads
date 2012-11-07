def calculate_q(k, n)
		# q is the smallest prime satisfying
		# q / log (q + 1) >= n * 2k * w( sqrt(k * log k))
		#
		# Using THETA notation, epsilon = 1


		# Using ceiling for now, until we actually find the
		# smallest prime bigger than this quantity
		(n * k * Math.log2(k) * Math.sqrt( k * Math.log2(k) )).ceil
end

def calculate_mu(k, q)
	2 * k * Math.log2(q).ceil
end

def calculate_beta(n, mu)
	n * Math.sqrt(mu)
end

def partial_digest(node_index, with_repect_to_index)
	if node_index.length == with_repect_to_index.length
		if node_index == with_repect_to_index

			# wrt itself defined to be vector of 1's
			return Matrix.build(@k ,1) { 1 }
		else
			raise RangeError
		end
	end

	# Check if wrt_index is in left or right subtree?
	#
	# Drop the characters of wrt_index that match the node_index
	# 	The first character of the remainder tells you
	# 	to go left or right

	if with_repect_to_index.sub(node_index, '')[0] == "0"
		# Left
		b_vector = binary_vector(partial_digest( node_index + '0' ,with_repect_to_index ) )
		return mod(@L * b_vector, @q)
	else
		#Right
		b_vector = binary_vector(partial_digest( node_index + '1' ,with_repect_to_index ) )
		return mod(@R * b_vector, @q)
	end
end


def node_digest
	#d(w) =SUM i∈range(w) ci ·Dw(i)
	#
	#
	#
end

def range

end


def binary_vector(x)

	b_parts = Array.new

	x.each do |ele|

		# Make each element in x into binary form
		# 	Add each bit to output vector
		bin = ele.to_s(2)

		(Math.log2(q).ceil - bin.length).times do
			b_parts << 0
		end

		bin.each_char do |bit|
			b_parts << bit.to_i

		end
	end

	Matrix.column_vector(b_parts)
end

def mod(matrix, q)
	Matrix.build(matrix.row_size, matrix.column_size) { |row, col|
			matrix[row, col] % q
	}
end

