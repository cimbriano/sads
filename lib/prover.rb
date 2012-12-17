require 'sads'

class Prover
	include Sads

	#Data structures storing Merkle tree
	attr_accessor :labels, :leaves, :digests, :partial_labels

	# Encryption key pair
	attr_reader :public_key, :secret_key

	#mu
	attr_reader :mu

	#beta
	attr_reader :beta

	# Upper bound on size of stream
	attr_reader :stream_bound_n

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
		@partial_labels = {}

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
		# 	* Update the root digest (this may occur as part of the previous

		index = get_leaf_index(ele)

		# Update leaves (frequencies)
		if leaves.include?(index)
			leaves[index] += 1
		else
			leaves[index] = 1
		end

		# Update labels for all nodes on the update path
		get_update_path(index).each do |path_index|
			update_label(path_index, index)
		end

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

	# Given a node index, returns a list of pairs of labels.
	# 		The pairs consist of
	# 			i) Label of node on the update path of node_index
	# 			ii) Sibling label of i)
	def get_membership_proof(node_index)
		update_path = get_update_path(node_index)

		update_path.map { |node| [node_label(node), node_label( sibling(node) ), right_child?(node) ] }
	end

	def get_range_proof(range)
		cover = cover(range)

		proof = Hash.new

		cover.each do |node_index|
			proof[node_index] = { 'siblings' => get_membership_proof(node_index), 'freqs' => get_frequency_table(node_index)}
		end

		return proof
	end

	def node_digest(node_index)
		 # If the digest has been computed and stored, use that, otherwise compute it
		 # @digests[node_index] ||= calc_node_digest(node_index)
		 calc_node_digest(node_index)
	end

	def node_label(node_index)
		 # If the digest has been computed and stored, use that, otherwise compute it
		 # @labels[node_index] ||= calc_node_label(node_index)
		 labels[node_index] || Vector.elements( Array.new(@k * @log_q_ceil) { 0 } )
	end


	# Given a node index, and an index of a
	def update_label(node_idx, wrt_index)
		# TODO Checking wrt is a valid index with which to update node index's label
		# puts "labels[#{node_idx}] = #{labels[node_idx]}"
		old_label = node_label(node_idx)
		labels[node_idx] = old_label + partial_label_wrapper(node_idx, wrt_index)
	end

	# private

	def init_L_R
		@L = Matrix.build(@k, @mu / 2) { rand @q }
		@R = Matrix.build(@k, @mu / 2) { rand @q }
	end



	def calculate_mu(k, q)
		2 * k * @log_q_ceil
	end


	def calculate_beta(n, mu)
		n * Math.sqrt(mu)
	end

	# Given any integer, return the binary representation of it such that
	# 	the length of the binary number is Math.log2(q).ceil
	def get_padded_binary(integer)
		binary_with_num_bits(integer, @log_q_ceil)
	end

	# Returns a collection of leaf indicies for the range of the given parameter
	#
	# The range of a leaf node is itself.
	def range(node_index)
		range = Array.new

		prefix = node_index

		suffix_length = @bits_needed_for_leaves - prefix.length
		if suffix_length == 0
			# This is a leaf, range of leaf is itself
			range << node_index
		else
			# prefix + _ _ _ where
			(0...2**suffix_length).each do |num|
				suffix = binary_with_num_bits(num, suffix_length)

				range << prefix + suffix
			end
		end

		return range
	end

	# Given a leaf index this method returns the path (indices) in the hash tree
	# 	from the leaf to the child of the root (ie, its a path to the
	# 	root without the root)
	def get_update_path(leaf_index)
		# Flat_map returns and array with the elements produced by each block
		2.upto(leaf_index.length).flat_map do | last |
			leaf_index[0, last]
		end.reverse
	end

	# Given a node index
	# 	returns the index of its sibling in the Merkle tree
	def sibling(node_index)
		if node_index[-1] ==  "0"
			node_index[0...-1] + '1'
		else
			node_index[0...-1] + '0'
		end
	end

	# Given a node index
	# 	returns the parent index
	def parent(index)
		if index.nil? || index.length == 1
			raise ArgumentError, "Root has no parent or index: #{index.nil? ? nil : index} was nil"
		end

		index[0...-1]
	end

	# Given a node index
	# 	returns true if this is the right (not left) child
	def right_child?(node_index)
		node_index[-1] == '1'
	end

	# Given a node index
	# 	Returns a hash of leaf index to that leaf's frequency
	def get_frequency_table(node_index)
		r = range(node_index)
		@leaves.select {|idx, freq| r.include? idx }
	end

	# Given a range of leaf nodes (by integer or by index)
	# 	return the cover (the set of internal nodes that "cover")
	# 	the specified range
	def calc_cover(range)
		raise RangeError, "#{range} is out of range" if range.first < 0 || range.last > @universe_size_m

		leaves = range.map { |e| get_leaf_index e }
		cover = []
		tmp = []


		while leaves.length > 0 || tmp.length > 0 do

			while leaves.length > 0 do
				e1 = leaves[0]
				e2 = leaves[1]

				if e2.nil?

					cover << e1
					leaves = leaves[1, leaves.length]

				elsif e1.length == e2.length

					if parent(e1) == parent(e2)
						tmp << parent(e1)
						#Loop on leaves shortened by two
						leaves = leaves[2, leaves.length]
					else
						cover << e1
						leaves = leaves[1, leaves.length]
					end

				else
					# Different lengths

					tmp << e1
					leaves = leaves[1, leaves.length]
				end

			end

			leaves = tmp
			tmp = []
		end

		return cover

	end

	# Public facing cover
	# 	first can have type Fixnum, String or Range.
	# 	if Fixnum, optinal last indicates end of range,
	# 		otherwise its a one element range
	# 	if String, must be a valid leaf index (same assumption with last as Fixnum)
	def cover(first, last=nil)
		case(first)
		when Fixnum
			if last
				return calc_cover(first..last)
			else
				return calc_cover(first..first)
			end
		when Range
			return calc_cover(first)
		else
			raise TypeError, "#{first} has invalid type #{first.class}"
		end
	end


	# Label as sum of partial labels: Definition 12
	#
	# Optimization: Use stored labels where possible.
	def calc_node_label(node_index)
		# TODO - This is repeated code from node_label and doesn't
		# 	take advantage of stored digests or labels

		# log_q_ceil = Math.log2(@q).ceil
		accum = Vector.elements( Array.new(@k * @log_q_ceil) { 0 } )

		range_of_w = range(node_index)

		range_of_w.each do | leaf |
			frequency = leaves[leaf] || 0
			p_label = partial_label_wrapper(node_index, leaf)
			accum += ( frequency * p_label )
		end

		return mod(accum, @q)
	end

	def partial_label_wrapper(node_index, leaf)
		if partial_labels[node_index].nil?
			partial_labels[node_index] = {}
		end

		partial_labels[node_index][leaf] ||= partial_label(node_index, leaf)
	end

	# Digest as a sum of partial digests: Definition 11.
	#
	# Optimization: Make use of a stored map of digests instead of calculating them
	# on the fly each time
	def calc_node_digest(node_index)
		#d(w) =SUM i∈range(w) ci ·Dw(i)

		# accum = Matrix.build(@k, 1) { 0 }

		accum = Vector.elements( Array.new(@k) { 0 } )

		range_of_w = range(node_index)

		# range_of_w.inject{ |acc, leaf| sum + (leaves[leaf] || 0) + partial_digest(node_index, leaf) }
		range_of_w.each do | leaf |
			# puts "leaf : #{leaf}"

			frequency = leaves[leaf] || 0
			# puts "freq of #{leaf} : #{frequency}"

			p_digest = partial_digest(node_index, leaf)
			# puts "p_digest of #{node_index} w.r.t #{leaf} : #{p_digest}"

			accum += ( frequency * p_digest )
			# puts "current accum : #{accum}"

		end

		modded_accum = mod(accum, @q)
		# puts "accum mod #{@q} : #{modded_accum}"

		return modded_accum
	end

	def hash_children_by_index(child_1, child_2)
		#TODO handle reverse children
		if child_1[-1] == '1'
			hash_children_by_label(node_label(child_1), node_label(child_2), reverse=true)
		else
			hash_children_by_label(node_label(child_1), node_label(child_2), reverse=false)
		end
	end


end # class Prover