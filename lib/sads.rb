# sads.rb
require 'matrix'
require 'sads_util'

class Sads

	#Data structures storing Merkle tree
	attr_accessor :labels, :leaves, :digests

	# Stores digest of root
	attr_accessor :root_digest

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

			@universe_size_m        = 4
			@k                      = 2
			@stream_bound_n         = 2
			@q                      = calculate_q(@k, @stream_bound_n)
			@log_q_ceil             = Math.log2(@q).ceil
			@bits_needed_for_leaves = Math.log2(@universe_size_m) + 1
			@mu                     = calculate_mu(@k, @q)

			l0 = [5, 1, 5, 1, 0, 1]
			l1 = [2, 1, 1, 3, 0, 3]

			r0 = [2, 4, 1, 4, 2, 5]
			r1 = [1, 0, 4, 3, 5, 3]

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
		@digests = {}

		@root_digest = node_digest('0')
	end # initialize

	# Add the specified element to the Merkle tree
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

		# update_root_digest
		@root_digest = mod(@root_digest + partial_digest('0', index), @q)
	end

	def removeElement(ele)
		# removeElement has to do the following:
		# 	* Update the leaves (or frequency value)
		# 	* Update the labels of all affected nodes
		# 	* Update the root digest (this may occur as part of the previous)
	end

	def exists?(ele)
		return leaves.include?(ele)
	end

	def node_digest(node_index)
		 # If the digest has been computed and stored, use that, otherwise compute it
		 # @digests[node_index] ||= calc_node_digest(node_index)
		 calc_node_digest(node_index)
	end

	def node_label(node_index)
		 # If the digest has been computed and stored, use that, otherwise compute it
		 # @labels[node_index] ||= calc_node_label(node_index)
		 calc_node_label(node_index)
	end

	# Given a proof provided by the prover, use this to verify its correctness
	def verify_membership_proof(proof)

		# Steps:
		# 	a. Compute the digest of a parent given the labels of its children (hash)
		# 			- The proof will have labels of the nodes (no indices?... should there be a proof class?)
		# 	b. Compute the digest of each node given its label
		# 	c. The digests of a. and b. should be consistent

		(proof.length - 1).times do |i|

			label_child_1, label_child_2, reverse_flag = proof[i]
			hashed_digest = hash(label_child_1, label_child_2, reverse_flag)

			parent_label  = proof[i + 1][0]

			matched = check_radix_label(parent_label, hashed_digest)



			return false if not matched
		end

		# d. Check the root digest is equivalent with the known digest
			# Check the hash of the last siblings is the root digest
		root_child_1, root_child_2, reverse_flag = proof.last

		return hash(root_child_1, root_child_2, reverse_flag) == @root_digest
	end


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

	# private below here
	def init_L_R
		@L = Matrix.build(@k, @mu / 2) { rand @q }
		@R = Matrix.build(@k, @mu / 2) { rand @q }
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

	# end private
end # class Sads