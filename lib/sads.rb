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

	def initialize(k, n, m)
		# Input parameteres?
		#  # Size of Universe
		#
		@universe_size_m = m
		@log_q_ceil = Math.log2(m).ceil

		@k = k
		@stream_bound_n = n

		@q = calculate_q(k, n)
		@mu   = calculate_mu(@k, @q)

		init_L_R

		@leaves = {}
		@labels = {}
	end


	def addElement(ele)
		# Need an index for this element (assuming for now element is
		# 	an integer representing which universe element to "add"
		#

		# addElement has to do the following:
		# 	* Update the leaves (or frequency value)
		# 	* Update the labels of all affected nodes
		# 	* Update the root digest (this may occur as part of the previous)

		num_in_bin = ele.to_s(2)
		index = '0' * (Math.log2(@universe_size_m).ceil + 1 - num_in_bin.length)
		index += num_in_bin

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
		@L * x + @R * y
	end
	# end private
end