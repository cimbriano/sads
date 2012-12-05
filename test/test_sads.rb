require 'helper'
require 'sads_helper'
require 'prime'

class TestSads < MiniTest::Unit::TestCase

	describe "Sads" do

		before do
			@sad = Sads.new(5,10,8)
		end

		describe "Sads Construction" do
			def test_constructor
				@sad.wont_be_nil
			end

			def test_mu_is_not_a_float
				Prime.each(100) do |q|

					(1..10).each do |k|

						@sad.calculate_mu(k, q).must_be_instance_of Fixnum
					end
				end
			end

			def test_calc_q
				assert_equal(29, @sad.calculate_q(2,10))
			end

			def test_calc_mu
				# skip "Skipping for now, dealing with refactoring @log_q"
				# assert_equal(12, @sad.calculate_mu(2,8))
				# assert_equal(16, @sad.calculate_mu(2,9))
			end

			def test_calc_beta
				assert_equal(6, @sad.calculate_beta(2,9))
				assert_in_delta(8.94, @sad.calculate_beta(2,20), 0.01)
			end
		end # describe Sads Construction

		describe "L & R Matrices" do
			def test_init_L_R_are_matricecs
				assert_instance_of(Matrix, @sad.L)
				assert_instance_of(Matrix, @sad.R)
			end

			def test_init_L_R_are_correct_size
				assert_equal( @sad.L.row_size, @sad.k)
				assert_equal( @sad.L.column_size, @sad.mu / 2)
				assert_equal( @sad.R.row_size, @sad.k)
				assert_equal( @sad.R.column_size, @sad.mu / 2)
			end

			def test_init_L_R_are_mod_q
				@sad.L.each do |item|
					assert(item < @sad.q)
				end

				@sad.R.each do |item|
					assert(item < @sad.q)
				end
			end

			def test_init_L_R_are_not_equal
				assert( false == @sad.L.eql?(@sad.R))
			end
		end # describe L & R matrices

		describe "hash function" do

			def test_hash_raises_error_for_unlike_types
				assert_raises(TypeError){
					@sad.hash('00', 0)
				}
			end

			def test_hash_raises_error_for_similar_types_not_string_or_vector
				assert_raises(TypeError){
					@sad.hash(0,0)
				}
			end

			def test_hash_result_is_a_vector
				m = @sad.mu / 2

				x = column_vector(m)
				y = column_vector(m)

				assert_instance_of(Vector, @sad.hash(x, y, false))
			end

			def test_hash_elements_are_mod_q
				m = @sad.mu / 2
				max = @sad.q * 4

				x = column_vector_with_max(m, max)
				y = column_vector_with_max(m, max)

				@sad.hash(x, y, false).each do |item|
					assert(item < @sad.q, "#{item} is >= #{@sad.q}")
				end
			end

			def test_hash_of_vectors_fails_without_parameter
				m = @sad.mu / 2

				v1 = column_vector(m)
				v2 = column_vector(m)

				assert_raises(ArgumentError){
					@sad.hash(v1,v2)
				}
			end

			def test_hash_of_string_checks_order

				zeroth = @sad.get_leaf_index(0)
				first  = @sad.get_leaf_index(1)

				assert_equal(@sad.hash(zeroth, first), @sad.hash(first, zeroth), "Hash of siblings (x,y) not equal to hash of (y,x)")
			end
		end # describe hash function

		describe "binary vector" do
			def test_binary_vector
				x = column_vector(@sad.k)

				b_vector = @sad.binary_vector(x)

				b_vector.must_be_instance_of Vector

				size = b_vector.size
				# b_columnsize = b_vector.column_size

				# m = k * log q
				expected_size = @sad.k * @sad.log_q_ceil


				assert_equal(expected_size, size, "Row size is #{size}")
				# assert_equal(1 ,b_columnsize, "Column size is: #{b_columnsize}")
			end
		end # describe binary vector

		describe "partial digest" do

			def test_partial_digest_wrt_itself
				# Digest of a node with respect to istelf should be a vector of 1

				# TODO - Test all elements in universe
				leaf_index = @sad.get_leaf_index(1)
				part_dig = @sad.partial_digest(leaf_index, leaf_index)

				part_dig.must_be_instance_of Vector
				assert_equal(@sad.k, part_dig.size, "Partial Digest rowsize: #{part_dig.size}")

				part_dig.each do |element|
					assert_equal(1, element, "Element of partial digest was #{element}")
				end
			end

			# def test_partial_digest_wrt_leaf_node

			# 	skip "Not sure how to test the application of L and R matrices"
			# 	# l_matrix = @sad.L
			# 	# r_matrix = @sad.R

			# 	# pd_00_3 = @sad.partial_digest(@sad.get_leaf_index(3), '00')
			# 	# puts "Partial Digest Calculated"

			# 	# unpacked_vector = l_matrix.inverse * pd_00_3

			# 	# unpacked_vector.each do |ele|
			# 	# 	assert_equal(1, ele, "Unpakced vector element was #{ele}")
			# 	# end

			# 	# pd_01_4 = @sad.partial_digest(@sad.get_leaf_index(4), '01')
			# end

			def test_partial_digest_in_Z_q

				addSomeElements(@sad, 10)

				all_nodes = set_of_all_node_indices(@sad)
				begin
					all_nodes.each do |node_index|

						# puts "Node_index: #{node_index}"

						leaf_range = @sad.range(node_index)

						leaf_range.each do |leaf|

							# puts "Leaf: #{leaf}"

							p_dig = @sad.partial_digest(node_index, leaf)

							p_dig.each do |ele|
								assert(ele < @sad.q, "Element was greater than q: #{ele}")
							end
						end
					end

				rescue ArgumentError => err
					puts err
					fail
				end
			end
		end # describe partial digest

		describe "node digest" do
			def test_node_digest_is_correct_type_and_size

				@sad.addElement(0)
				zeroth_digest = @sad.node_digest( @sad.get_leaf_index(0) )

				zeroth_digest.must_be_instance_of Vector
				assert_equal(@sad.k, zeroth_digest.size, "Digest Row Size is: #{zeroth_digest.size}")
			end

			def test_node_digest_in_Z_q
				addSomeElements(@sad, 10)

				all_nodes = set_of_all_node_indices(@sad)
				all_nodes.each do |node_index|
					digest = @sad.node_digest(node_index)

					digest.each do |ele|
						assert(ele < @sad.q, "Element: #{ele} was expected to be less than #{@sad.q}")
					end
				end
			end
		end # describe node digest

		describe "partial label" do

			def test_partial_label_size
				begin
					p_label = @sad.partial_label('01', '0110')
					assert_equal(@sad.k * @sad.log_q_ceil, p_label.size, "Size of p_label was #{p_label.size}")
				rescue ArgumentError => err

					puts err.backtrace
					puts "Error Message"

				end
			end
		end # describe partial label

		describe "node label" do

			def test_node_label_is_correct_type_and_size

				@sad.addElement(0)
				zeroth_label = @sad.node_label( @sad.get_leaf_index(0) )

				zeroth_label.must_be_instance_of Vector
				assert_equal(@sad.k * @sad.log_q_ceil, zeroth_label.size, "Label Size is: #{zeroth_label.size}")
			end


			def test_node_label_in_Z_q
				addSomeElements(@sad, 20)

				all_nodes = set_of_all_node_indices(@sad)
				all_nodes.each do |node_index|
					label = @sad.node_label(node_index)

					label.each do |ele|
						assert(ele < @sad.q, "Element: #{ele} was expected to be less than #{@sad.q}")
					end
				end

			end
		end # describe node label

		describe "range" do
			def test_range_of_self
				# Range of leaf is just itself
				expected_length_of_leaf_indices = @sad.bits_needed_for_leaves

				all_nodes = set_of_all_node_indices(@sad)
				all_nodes.each do |node_index|
					if node_index.length < expected_length_of_leaf_indices
						# We only want to assert for leaf nodes
					else
						# Have a leaf index
						actual_range = @sad.range(node_index)
						assert(actual_range.include?(node_index), "#{node_index} wasn't in #{actual_range}")

						# Leaf was the only element in the range
						assert(actual_range.size == 1, "Range had more than just leaf_node")
					end

				end

			end

			def test_range_returns_indices_of_correct_length
				num_bits_needed = @sad.bits_needed_for_leaves

				act_range = @sad.range('0')

				act_range.each do |leaf|
					assert_equal(num_bits_needed, leaf.length, "Leaf length is: #{leaf.length}")
				end
			end

			def test_range_of_root_is_whole_universe
				act_range = @sad.range('0')
				assert_equal(@sad.universe_size_m, act_range.length, "Range size is: #{act_range.length}")
			end

			def test_range_of_internal_node
				leaf_length = @sad.bits_needed_for_leaves
				all_node_indicies = set_of_all_node_indices(@sad)
				internal_nodes = all_node_indicies.reject {|ele| ele.length == leaf_length || ele.length == 1  }
				internal_nodes.each do |internal_node|
					extra_bits_needed = leaf_length - internal_node.length
					act_range = @sad.range(internal_node)
					expected_num_of_nodes_in_range = 2 ** extra_bits_needed
					assert_equal(expected_num_of_nodes_in_range, act_range.length, " Range of :#{internal_node} had the size: #{act_range.length} ")
				end

			end
		end # describe range

		describe "get leaf index" do
			def test_get_leaf_index
				bit_length = @sad.bits_needed_for_leaves

				(0...@sad.universe_size_m).each do |element_number|
					n_index = @sad.get_leaf_index(element_number)

					assert_equal(bit_length, n_index.length,
						"node_index was not the expected length. Node: #{element_number} had index #{n_index}")

					assert_equal(element_number, n_index.to_i(2), "Element was different than expected: #{element_number} != #{n_index} in base 2")
				end

			end

			def test_get_leaf_index_raises_error_for_bad_input

				bad_input = @sad.universe_size_m + 1

				assert_raises(RangeError){
					@sad.get_leaf_index(bad_input)
				}
			end
		end # describe get leaf index

		describe "sads util methods" do
			describe "mod" do
				def test_mod
					m = Matrix.build(10, 10) { rand 100 }

					mod(m, 8).each do |ele|
						assert(ele < 8)
					end

				end
			end #describe mod

			describe "check radix int/label" do

				it "should raise an error if the dimensions are incorrect" do

					label  = [1,2,3]
					digest = [1,2,3]

					assert_raises(TypeError){
						@sad.check_radix_label(label, digest)
					}
				end
			end #describe check radix

			def test_right_child
				all_nodes = set_of_all_node_indices(@sad)
				all_nodes.each do |node|
					assert_equal(node[-1] == '1', @sad.right_child?(node), "#{node} is a left child")
				end
			end

			describe "frequency table" do

				def test_table_for_leaf_only_includes_leaf
					@sad.addElement 0
					leaf            = @sad.get_leaf_index 0
					frequency_table = @sad.get_frequency_table(leaf)

					assert_equal( 1, frequency_table.size, "Freq table size incorrect.")
					assert( frequency_table.include?(leaf), "Leaf not included in its own freq table")
					assert_equal( @sad.leaves[leaf], frequency_table[leaf], "Wrong frequncy returned")
				end

				def test_table_for_root_include_all_leaves
					all_leaves      = set_of_leaf_indices(@sad)


					(0...@sad.universe_size_m).each do |ele|
						@sad.addElement ele
					end

					frequency_table = @sad.get_frequency_table('0')
					assert_equal(all_leaves.size, frequency_table.size, "Freq table did not include all leaves")
				end



			end # describe frequency table
		end # describe helper methods

		describe "test helper methods" do
			def test_all_set_of_all_nodes
				num_leaves = @sad.universe_size_m
				expected_nodes = 2 * num_leaves - 1

				nodes = set_of_all_node_indices(@sad)

				assert_equal(expected_nodes, nodes.size, "Set of nodes was incorrect size: #{nodes}")
			end

			def test_set_of_all_leaves
				leaves = set_of_leaf_indices(@sad).size
				assert_equal(@sad.universe_size_m, leaves, "Set of leaves not right size: #{leaves}")
			end
		end # describe

		describe "binary with num bits" do
			def test_binary_with_num_bits
				expected = '000'
				actual = @sad.binary_with_num_bits(0, 3)
				assert_equal(expected, actual)

				expected = '100'
				actual = @sad.binary_with_num_bits(4, 3)
				assert_equal(expected, actual)

				expected = '101'
				actual = @sad.binary_with_num_bits(5, 3)
				assert_equal(expected, actual)

				expected = '111'
				actual = @sad.binary_with_num_bits(7, 3)
				assert_equal(expected, actual)
			end

			def test_raises_error_for_intergers_too_big
				assert_raises(ArgumentError){
					@sad.binary_with_num_bits(100, 4)
				}
			end
		end # describe binary with num bits

		describe "update path" do

			def test_get_update_path_does_not_include_root
				update_path = @sad.get_update_path( @sad.get_leaf_index(0) )

				update_path.wont_include '0'
			end


			def test_get_update_path_has_correct_number_of_node_indices
				update_path = @sad.get_update_path( @sad.get_leaf_index(0) )

				# Expect one less than num bits needed (root is not on update path)
				expected_length = @sad.bits_needed_for_leaves - 1

				assert_equal(expected_length, update_path.length, "Update path had #{update_path.length} elements.")
			end

			def test_update_path_order
				leaf_indices = set_of_leaf_indices(@sad)

				leaf_indices.each do |idx|
					update_path  = @sad.get_update_path(idx)

					(update_path.length - 1).times do |i|
						assert( update_path[i].length == update_path[i + 1].size + 1, "update path: #{update_path}")
					end
				end

			end
		end # describe update path

		describe "correctness conditions" do

			def test_digest_is_radix_of_label

				assert(@sad.leaves.empty?, "Sads leaves is not empty: #{@sad.inspect}")
				addSomeElements(@sad, 9)

				all_nodes = set_of_all_node_indices(@sad)
				all_nodes.each do |node|
					digest = @sad.node_digest(node)
					label = @sad.node_label(node)


					# puts "Checking label: #{label}"
					# puts "Checking digest: #{digest}"
					# puts "q : #{@sad.q}"

					assert(@sad.check_radix_label(label, digest), "Label/Digest Relation Failed for node: #{node}")
				end
			end

			def test_digest_is_hash_of_child_labels

				assert(@sad.leaves.empty?, "Sads leaves is not empty: #{@sad.inspect}")
				addSomeElements(@sad, 9)


				all_nodes = set_of_all_node_indices(@sad)
				internal_nodes = all_nodes.reject {|ele| ele.length == @sad.bits_needed_for_leaves }

				internal_nodes.each do |internal_node|
					calculated_digest = @sad.node_digest(internal_node)

					hashed_digest = @sad.hash(internal_node + '0' , internal_node + '1')
					assert_equal(calculated_digest, hashed_digest, "Hashed digest did not equal caclulated digest.")
				end
			end
		end # describe correctness conditions

		describe "siblings (membership proof)" do

			def test_siblings_correct_length

				# TODO Test all the leaves
				siblings_labels = @sad.get_membership_proof( @sad.get_leaf_index(1) )
				tree_depth = @sad.bits_needed_for_leaves

				assert_equal(tree_depth - 1, siblings_labels.length, "Proof had #{siblings_labels.length} elements. #{tree_depth - 1} expected")
			end

			def test_siblings_is_list_of_pairs
				leaf_index = @sad.get_leaf_index(1)

				siblings_labels = @sad.get_membership_proof( leaf_index )

				update_path = @sad.get_update_path leaf_index

				update_path.each_with_index do |node_index, i|

					label1 = @sad.node_label node_index
					label2 = @sad.node_label @sad.sibling(node_index)

					child_label1, child_label2 = siblings_labels[i]

					assert_equal(label1, child_label1)
					assert_equal(label2, child_label2)
				end
			end

			# def test_order_of_pairs
			# 	leaf_indices = set_of_leaf_indices(@sad.universe_size_m, @sad.bits_needed_for_leaves)

			# 	leaf_indices.each do |leaf_index|
			# 		siblings_labels = @sad.get_membership_proof leaf_index

			# 		parent(leaf_index)
			# 	end

			# end
		end # describe siblings

		describe "verify_membership_proof" do
			def test_membership_proof

				addSomeElements(@sad, 8)

				# TODO Test all the leaves
				leaves = set_of_leaf_indices(@sad)

				proof = @sad.get_membership_proof( @sad.get_leaf_index(1) )

				assert( @sad.verify_membership_proof(proof) , "Proof does not check out")
			end
		end # describe verification

		describe "cover" do
			def test_raise_error_for_elements_out_of_range
				assert_raises(RangeError){
					@sad.cover(0...@sad.universe_size_m + 1)
				}

				assert_raises(RangeError){
					@sad.cover(-1...@sad.universe_size_m)
				}

				assert_raises(RangeError){
					@sad.cover(-1, 1)
				}

				assert_raises(RangeError){
					@sad.cover(0, @sad.universe_size_m + 1)
				}

				#Doesn't raise hack.
				assert(@sad.cover(0...@sad.universe_size_m).is_a? Object)
			end

			def test_cover_of_single_index

				element_number = rand(@sad.universe_size_m)
				leaf_index     = @sad.get_leaf_index( element_number )
				cover          = @sad.cover(element_number)

				assert_equal(1, cover.size, "Cover not the right size")
				assert(cover.include?(leaf_index), "Cover: #{cover} did not include #{leaf_index}")
			end

			def test_cover_of_two_with_same_parent_is_parent

				cover      = @sad.cover(0, 1)
				leaf_index = @sad.get_leaf_index 0
				parent     = @sad.parent leaf_index

				assert_equal(1, cover.size, "Cover: #{cover} not the right size")
				assert( cover.include?(parent), "Cover: #{cover} did not include #{parent}")
			end

			def test_cover_of_two_adjacent_leaves_with_different_parents

				cover        = @sad.cover(1, 2)
				leaf_index_0 = @sad.get_leaf_index 1
				leaf_index_1 = @sad.get_leaf_index 2

				assert_equal(2, cover.size, "Cover: #{cover} not the right size")
				assert( cover.include?(leaf_index_0), "Cover: #{cover} did not include #{leaf_index_0}")
				assert( cover.include?(leaf_index_1), "Cover: #{cover} did not include #{leaf_index_1}")
			end

			def test_cover_of_universe_is_root
				cover = @sad.cover(0, @sad.universe_size_m - 1)

				assert(cover.include?('0'), "Cover: #{cover} should include root")
				assert_equal(1, cover.size, "Cover: #{cover} should only include root element")

			end
		end # describe cover

		describe "range proof" do
			def test_range_proof_attributes
				addSomeElements(@sad, 10)

				proof = @sad.get_range_proof(0...@sad.universe_size_m)

				proof.each do |ele|
				end
				skip "Not implemented"
			end
		end # describe range proof

		describe "verify range proof" do
			def test_correctness
				addSomeElements(@sad, 10)

				proof = @sad.get_range_proof(0...@sad.universe_size_m)

				assert(@sad.verify_range_proof(proof), "Proof failed verification")
			end
		end # describe verify range proof

	end # describe Streaming Authenticated Data Structure
end # TestSads
