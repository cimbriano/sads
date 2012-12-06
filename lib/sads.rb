require 'matrix'

module Sads

	# Security Parameter
	attr_reader :k

	# q
	attr_accessor :q

	# loq_q
	attr_reader :log_q_ceil

	# Stores digest of root
	attr_accessor :root_digest

	# Size of Universe
	attr_reader :universe_size_m

	# Left and Right vectors for algebraic hash function
	attr_accessor :L, :R

	# Public hash method, expects two strings representing indices, or two Vectors representing labels
	def hash(x,y, reverse=nil)
		raise TypeError, "#{x} and #{y} have different types." if x.class != y.class

		case x
		when String
			return hash_children_by_index(x,y)
		when Vector
			raise ArgumentError, "<reverse> parameter not provided" if reverse.nil?
			return hash_children_by_label(x,y,reverse)
		else
			raise TypeError, "hash takes either a Vector or a String index"
		end
	end

	# private

	def calculate_q(k, n)
		# q is the smallest prime satisfying
		# q / log (q + 1) >= n * 2k * w( sqrt(k * log k))
		#
		# Using THETA notation, epsilon = 1


		# Using ceiling for now, until we actually find the
		# smallest prime bigger than this quantity
		(n * k * Math.log2(k) * Math.sqrt( k * Math.log2(k) )).ceil
	end

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



	# The algebraic hash function.
	# Takes as parameters the indicies of two child nodes and
	# 	produces the digest of the parent of those children.
	def hash_children_by_label(child_1, child_2, reverse)
		if reverse
			mod(@L * child_2 + @R * child_1, @q)
		else
			mod(@L * child_1 + @R * child_2, @q)
		end
	end

	# Partial label as mentioned in Definition 10.
	def partial_label(node_index, with_repect_to_index)
		binary_vector(partial_digest(node_index, with_repect_to_index))
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

			p_dig = partial_digest( node_index + '0' ,with_repect_to_index )
			b_vector = binary_vector( mod(p_dig, @q) )

			return mod(@L * b_vector, @q)
		else
			#Right

			p_dig = partial_digest( node_index + '1' ,with_repect_to_index )
			b_vector = binary_vector( mod(p_dig, @q) )

			return mod(@R * b_vector, @q)
		end
	end





	# Returns a vector ov size k * log q where each element is 0 or 1
	#
	# For now, the vector is storing Ruby's integers 0 or 1.  A future
	# optimization could be to store only the requisite bits.
	#
	# Pre-contidion: vector is in Z_q, otherwise, this can produce vectors not in Z_(k * m)
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

	# Returns the binary representation of integer using the
	# specified number of bits
	#
	# raises Arguement error of num_bits is notsufficiently large to represent
	# integer. eg. integer = 15 num_bits=2
	def binary_with_num_bits(integer, num_bits)
	binary = integer.to_s(2)

	padding_needed = num_bits - binary.length
	raise ArgumentError, "#{integer} can't be represented in #{num_bits} bits" unless padding_needed >= 0

	index = '0' * padding_needed + binary
	return index
	end

	# Given an integer representing the desired universe element
	# 	returns the appropriate leaf index for this tree's parameters
	def get_leaf_index(integer)

		if integer < 0 or integer >= @universe_size_m
			raise RangeError, "#{integer} is outside accepatable range for get_leaf_index"
		end

		binary_with_num_bits(integer, @bits_needed_for_leaves)
	end

	# Checks that radix is a radix representation of
	# 	the integer x mod q
	def check_radix_int(radix, x)
		# x is a number in Z_q
		#
		# radix is a vector in Z_q with size log q
		acc = 0
		radix.reverse.each_with_index do |r_i, i|
			acc += (r_i * (2 ** i))
		end

		return x == (acc % @q)
	end


	# Checks that the label is a radix representation of digest mod q
	# 	Both label and digest are expected to be Vectors or Arrays
	def check_radix_label(label, digest)

		raise TypeError, "Size mismatch between label and digest" if label.size != digest.size * @log_q_ceil
		# label should be a radix rep of the digest
		chunk_size = Math.log2(q).ceil

		label.each_slice(chunk_size).each_with_index do |group, i|
			return false unless check_radix_int(group, digest[i])
		end

		return true
	end

end # module Sads