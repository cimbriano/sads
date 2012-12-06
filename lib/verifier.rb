require 'sads'

class Verifier
	include Sads

	# Stores digest of root
	attr_accessor :root_digest

	# Left and Right vectors for algebraic hash function
	attr_reader :L, :R


	def update_root_digest(ele)
		@root_digest = mod(@root_digest + partial_digest('0', get_leaf_index(ele) ), @q)
	end
end