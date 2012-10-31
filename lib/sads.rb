# sads.rb
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

	def initialize()
		# Input parameteres?
		#  # Size of Universe
		
		@k = 500
		# @stream_bound_n = poly(k)
		

		@labels = {}
		@leaves = {}
		# @digest = 0
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

	private do	

		def calculate_q(n, k, w)
			# q is the smallest prime satisfying
			# 
			# q / log (q + 1) >= n * 2k * w( sqrt(k * log k))
		end

		def calculate_mu(k, q)
			#2 * k * round_up(log q)
		end

		def calculate_beta(n, mu)
			n * Math.sqrt(mu)
		end
	end # private

end
