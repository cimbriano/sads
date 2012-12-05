class Verifier
	extend Sads

	# Stores digest of root
	attr_accessor :root_digest

	# Left and Right vectors for algebraic hash function
	attr_reader :L, :R

	def initialize(l, r)
		@L = l
		@R = r

	end
end