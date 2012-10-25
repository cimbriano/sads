# sads.rb

class Sads
	
	attr_accessor :labels, :leaves, :digest
	attr_reader :L, :R, :pubkey

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
