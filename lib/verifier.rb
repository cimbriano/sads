require 'sads'

class Verifier
	include Sads

	#TODO - check_radix_int requires @q
	#TODO - check_radix_label requires @log_q_ceil

	def initialize(k, n, q, log_q_ceil, l, r)
		@k = k
		@n = n
		@q = q
		@log_q_ceil = log_q_ceil
		@L = l
		@R = r
		@root_digest = Vector.elements( Array.new(@k) { 0 } )
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

			# puts "Siblings"
			# puts "#{membership_proof}"
			# puts "Frequencies"
			# puts "#{freqs}"

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



	private

	# Checks that radix is a radix representation of
	# 	the integer x mod q
	def check_radix_int(radix, x)
		# x is a number in Z_q
		#
		# radix is a vector in Z_q with size log q
		acc = 0
		radix.reverse.each_with_index do |r_i, i|
			acc += (r_i * (2 ** i))
		end

		return x == (acc % @q)
	end


	# Checks that the label is a radix representation of digest mod q
	# 	Both label and digest are expected to be Vectors or Arrays
	def check_radix_label(label, digest)

		raise TypeError, "Size mismatch between label and digest" if label.size != digest.size * @log_q_ceil
		# label should be a radix rep of the digest
		chunk_size = Math.log2(q).ceil

		label.each_slice(chunk_size).each_with_index do |group, i|
			return false unless check_radix_int(group, digest[i])
		end

		return true
	end
end