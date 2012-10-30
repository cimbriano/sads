# sads.rb

class Sads
	
	attr_accessor :labels, :leaves, :digest

	# Security Parameter
	attr_reader :k

	# Left and Right vectors for algebraic hash function
	attr_reader :L, :R

	# Encryption key pair
	attr_reader :public_key, :secret_key

	def initialize()
		# Input parameteres?
		#  # Size of Universe

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

end
