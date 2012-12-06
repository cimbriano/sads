require 'sads'

class Verifier
	include Sads

	#TODO - check_radix_int requires @q
	#TODO - check_radix_label requires @log_q_ceil

	def initialize(k, n, q, log_q_ceil, l, r, m)
		@k = k
		@n = n
		@q = q
		@log_q_ceil = log_q_ceil
		@L = l
		@R = r
		@root_digest = Vector.elements( Array.new(@k) { 0 } )
		@universe_size_m = m
		@bits_needed_for_leaves = Math.log2(@universe_size_m) + 1
	end

	def update_root_digest(ele)
		@root_digest = mod(@root_digest + partial_digest('0', get_leaf_index(ele) ), @q)
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

	# Given a range proof
	# 	verify its correctness
	def verify_range_proof(proof)
		# For each node in the cover (ie, each key in proof)

		proof.each do |cover_index, proof_parts|

			membership_proof = proof_parts['siblings']
			freqs = proof_parts['freqs']

			# Calculate this nodes label from given frequencies and calculated partial labels
			cover_index_label = Vector.elements( Array.new(@k * @log_q_ceil) { 0 } )
			freqs.each do |leaf_index, frequency|
				p_label = partial_label(cover_index, leaf_index)
				cover_index_label +=  p_label * frequency
			end

			# label of cover node calculated.  Compare this to label provided in the proof
				# caveat -> if the cover label is the root,
				# 	then the proof['siblings'] doesn't have anything
			if 0 != membership_proof.size
				return false if siblings[0][0] != cover_index_label
				return verify_membership_proof(membership_proof)
			else
				return check_radix_label(cover_index_label, @root_digest)
			end
		end
	end

	# private

end # class Verifier