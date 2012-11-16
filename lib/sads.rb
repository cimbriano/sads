# sads.rb
require 'matrix'
require 'sads_util'

class Sads

	attr_accessor :labels, :leaves, :digest

	# Left and Right vectors for algebraic hash function
	attr_reader :L, :R

	# Encryption key pair
	attr_reader :public_key, :secret_key

	# Security Parameter
	attr_reader :k

	# Size of Universe
	attr_reader :universe_size_m

	# Upper bound on size of stream
	attr_reader :stream_bound_n

	# Algorithm Paramters
	# q
	attr_reader :q

	#mu
	attr_reader :mu

	#beta
	attr_reader :beta

	# loq_q
	attr_reader :log_q_ceil

	# Bits needed for leaf indices
	attr_reader :bits_needed_for_leaves

	def initialize(k, n, universe_size, test=false)
		@test = test

		if @test
			# Small universe and parameters and fixed L & R matrices for
			# 	easier testing

			@universe_size_m        = 2
			@k                      = 2
			@stream_bound_n         = 2
			@q                      = calculate_q(@k, @stream_bound_n)
			@log_q_ceil             = Math.log2(@q).ceil
			@bits_needed_for_leaves = Math.log2(@universe_size_m) + 1
			@mu                     = calculate_mu(@k, @q)

			l0 = [2, 0, 3, 5, 5, 2]
			l1 = [1, 1, 2, 5, 2 ,0]

			r0 = [0, 3, 0, 5, 5, 5]
			r1 = [3, 5, 5, 3, 4, 0]

			@L = Matrix.rows([l0, l1])
			@R = Matrix.rows([r0, r1])

		else
			@universe_size_m        = universe_size
			@k                      = k
			@stream_bound_n         = n
			@q                      = calculate_q(k, n)
			@log_q_ceil             = Math.log2(@q).ceil
			@bits_needed_for_leaves = Math.log2(@universe_size_m) + 1
			@mu                     = calculate_mu(@k, @q)

			init_L_R
		end

		@leaves = {}
		@labels = {}

	end # initialize


	def addElement(ele)
		# Need an index for this element (assuming for now element is
		# 	an integer representing which universe element to "add"
		#

		# addElement has to do the following:
		# 	* Update the leaves (or frequency value)
		# 	* Update the labels of all affected nodes
		# 	* Update the root digest (this may occur as part of the previous)

		index = get_leaf_index(ele)

		if leaves.include?(index)
			leaves[index] += 1
		else
			leaves[index] = 1
		end
	end

	def removeElement(ele)
		leaves.delete ele
	end

	def exists?(ele)
		return leaves.include?(ele)
	end

	# private below here
	def init_L_R
		@L = Matrix.build(@k, @mu / 2) { rand @q }
		@R = Matrix.build(@k, @mu / 2) { rand @q }
	end

	def hash(x, y)
		mod(@L * x + @R * y, @q)
	end
	# end private
end