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

	def calculate_q(n, k)
		# q is the smallest prime satisfying
		#
		# q / log (q + 1) >= n * 2k * w( sqrt(k * log k))

		# Temporarily Set to arbirary value
		n * k
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
