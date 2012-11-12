class Sads
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
		2 * k * @log_q_ceil
	end


	def calculate_beta(n, mu)
		n * Math.sqrt(mu)
	end

	# Partial label as mentioned in Definition 10.
	def partial_label(node_index, with_repect_to_index)
		binary_vector(partial_digest(node_index, with_repect_to_index))
	end


	# Label as sum of partial labels: Definition 12
	#
	# Optimization: Use stored labels where possible.
	def node_label(node_index)
		# TODO - This is repeated code from node_label and doesn't
		# 	take advantage of stored digests or labels

		# log_q_ceil = Math.log2(@q).ceil
		accum = Vector.elements( Array.new(@k * @log_q_ceil) { 0 } )

		range_of_w = range(node_index)

		range_of_w.each do | leaf |
			frequency = leaves[leaf] || 0
			p_label = partial_label(node_index, leaf)
			accum += ( frequency * p_label )
		end

		return accum
	end

	# Partial digest as defined in Definition 10.
	#
	# Likely candidate for optimization as this calculates each partial digest fresh
	def partial_digest(node_index, with_repect_to_index)
		if node_index.length == with_repect_to_index.length
			if node_index == with_repect_to_index

				# wrt itself defined to be vector of 1's
				return Vector.elements( Array.new(@k) { 1 } )
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

	# Digest as a sum of partial digests: Definition 11.
	#
	# Optimization: Make use of a stored map of digests instead of calculating them
	# on the fly each time
	def node_digest(node_index)
		#d(w) =SUM i∈range(w) ci ·Dw(i)

		# accum = Matrix.build(@k, 1) { 0 }

		accum = Vector.elements( Array.new(@k) { 0 } )

		range_of_w = range(node_index)

		# range_of_w.inject{ |acc, leaf| sum + (leaves[leaf] || 0) + partial_digest(node_index, leaf) }
		range_of_w.each do | leaf |
			frequency = leaves[leaf] || 0
			p_digest = partial_digest(node_index, leaf)
			accum += ( frequency * p_digest )
		end

		return accum
	end

	# Returns a collection of leaf indicies for the range of the given parameter
	#
	# The range of a leaf node is itself.
	def range(node_index)
		range = Array.new

		prefix = node_index

		suffix_length = @bits_needed_for_leaves - prefix.length
		if suffix_length == 0
			# This is a leaf, range of leaf is itself
			range << node_index
		else
			# prefix + _ _ _ where
			(0...2**suffix_length).each do |num|
				suffix = binary_with_num_bits(num, suffix_length)

				range << prefix + suffix
			end
		end

		return range
	end

	# Returns a vector ov size k * log q where each element is 0 or 1
	#
	# For now, the vector is storing Ruby's integers 0 or 1.  A future
	# optimization could be to store only the requisite bits.
	def binary_vector(vector)

		b_parts = Array.new

		vector.each do |ele|

			bin = binary_with_num_bits(ele, @log_q_ceil)

			bin.each_char do |bit|
				b_parts << bit.to_i
			end
		end

		Vector.elements(b_parts)
	end
	# Given a leaf index this method returns the path in the hash tree
	# 	from the leaf to the child of the root (ie, its a path to the
	# 	root without the root)
	def get_update_path(leaf_index)

	end

	# Given an integer representing the desired universe element
	# 	returns the appropriate leaf index for this tree's parameters
	def get_leaf_index(integer)

		if integer < 0 or integer >= @universe_size_m
			raise RangeError, "#{integer} is outside accepatable range for get_leaf_index"
		end

		'0' + binary_with_num_bits(integer, @log_q_ceil)
	end

	# Given any integer, return the binary representation of it such that
	# 	the length of the binary number is Math.log2(q).ceil
	def get_padded_binary(integer)
		binary_with_num_bits(integer, @log_q_ceil)
	end


	#
	def binary_with_num_bits(integer, num_bits)
		binary = integer.to_s(2)

		padding_needed = num_bits - binary.length

		index = '0' * padding_needed + binary
	end

end #Sads


# The mod function is a short term fix for doing all the arithmetic mod q
# 	Consider doing the mod operation during the actualy operations
# 	if possible (i.e when building a matrix)
#
# 	For matrix mutlpication cases, maybe a library can do that?
def mod(m, q)
	case(m)
	when Vector
		return Vector.elements( Array.new(m.size) {|i| m[i] % q })
	when Matrix
		return Matrix.build(m.row_size, m.column_size) { |row, col| m[row, col] % q }
	when Numeric
		return m % q
	else
		raise TypeError "mod(m,q) takes either a Vector or Matrix for m"
	end
end


