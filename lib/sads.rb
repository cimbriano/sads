# sads.rb
require 'matrix'

class Sads

	attr_accessor :labels, :leaves, :digest

	# Left and Right vectors for algebraic hash function
	attr_reader :L, :R

	# Encryption key pair
	attr_reader :public_key, :secret_key

	# Security Parameter
	attr_reader :k

	# Size of Universe
	attr_reader :universe_size_M

	# Upper bound on size of stream
	attr_reader :stream_bound_n

	# Algorithm Paramters
	# q
	attr_reader :q

	#mu
	attr_reader :mu

	#beta
	attr_reader :beta

	def initialize(k, n)
		# Input parameteres?
		#  # Size of Universe

		@k = k
		@stream_bound_n = n

		@q = calculate_q(k, n)
		@mu   = calculate_mu(@k, @q)

		init_L_R

	end


	def addElement(ele)
		leaves.store(ele, 1)
	end

	def removeElement(ele)
		leaves.delete ele
	end

	def exists?(ele)
		return leaves.include?(ele)
	end

	# private below here

	def partial_digest(node_index, with_repect_to_index)
		if node_index.length == with_repect_to_index.length

			if node_index == with_repect_to_index

				return "1"
				# return Matrix.build(1, @k) { 1 }
			else
				raise RangeError
			end
		end

		# is wrt_index in left or right subtree
		#
		# Drop the characters of wrt_index that match the node_index
		# 	The first character of the remainder tells you
		# 	to go left or right
		if with_repect_to_index.sub(node_index, '')[0] == "0"
			# Left
			# return "L( " + partial_digest( node_index + '0' ,with_repect_to_index )
			return @L * binary_vector(partial_digest( node_index + '0' ,with_repect_to_index ) )
		else
			#Right
			# return "R( " + partial_digest( node_index + '1' ,with_repect_to_index )
			return @R * binary_vector(partial_digest( node_index + '1' ,with_repect_to_index ) )
		end
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

	def init_L_R
		@L = Matrix.build(@k, @mu / 2) { rand @q }
		@R = Matrix.build(@k, @mu / 2) { rand @q }
	end

	def hash(x, y)
		@L * x + @R * y
	end
	# end private
end
