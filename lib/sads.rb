require 'matrix'

module Sads

	# Security Parameter
	attr_reader :k

	# q
	attr_reader :q

	# loq_q
	attr_reader :log_q_ceil

	# Stores digest of root
	attr_accessor :root_digest

	# Size of Universe
	attr_reader :universe_size_m

	# Left and Right vectors for algebraic hash function
	attr_reader :L, :R

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

	def hash_children_by_index(child_1, child_2)
		#TODO handle reverse children
		if child_1[-1] == '1'
			hash_children_by_label(node_label(child_1), node_label(child_2), reverse=true)
		else
			hash_children_by_label(node_label(child_1), node_label(child_2), reverse=false)
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
			#

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

end # module Sads