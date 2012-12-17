require 'helper'
require 'sads_helper'
require 'prover'
require 'prime'

class TestProver < MiniTest::Unit::TestCase
describe "Prover" do
	before do
		@prover = Prover.new(5,10,8)
	end

	describe "Construction" do
		def test_constructor
			@prover.wont_be_nil
		end

		def test_mu_is_not_a_float
			Prime.each(100) do |q|

				(1..10).each do |k|

					@prover.calculate_mu(k, q).must_be_instance_of Fixnum
				end
			end
		end

		def test_calc_q
			assert_equal(29, @prover.calculate_q(2,10))
		end

		def test_calc_mu
			# skip "Skipping for now, dealing with refactoring @log_q"
			# assert_equal(12, @prover.calculate_mu(2,8))
			# assert_equal(16, @prover.calculate_mu(2,9))
		end

		def test_calc_beta
			assert_equal(6, @prover.calculate_beta(2,9))
			assert_in_delta(8.94, @prover.calculate_beta(2,20), 0.01)
		end
	end # describe Sads Construction

	describe "L & R Matrices" do
		def test_init_L_R_are_matricecs
			assert_instance_of(Matrix, @prover.L)
			assert_instance_of(Matrix, @prover.R)
		end

		def test_init_L_R_are_correct_size
			assert_equal( @prover.L.row_size, @prover.k)
			assert_equal( @prover.L.column_size, @prover.mu / 2)
			assert_equal( @prover.R.row_size, @prover.k)
			assert_equal( @prover.R.column_size, @prover.mu / 2)
		end

		def test_init_L_R_are_mod_q
			@prover.L.each do |item|
				assert(item < @prover.q)
			end

			@prover.R.each do |item|
				assert(item < @prover.q)
			end
		end

		def test_init_L_R_are_not_equal
			assert( false == @prover.L.eql?(@prover.R))
		end
	end # describe L & R matrices

	describe "get leaf index" do
		def test_get_leaf_index
			bit_length = @prover.bits_needed_for_leaves

			(0...@prover.universe_size_m).each do |element_number|
				n_index = @prover.get_leaf_index(element_number)

				assert_equal(bit_length, n_index.length,
					"node_index was not the expected length. Node: #{element_number} had index #{n_index}")

				assert_equal(element_number, n_index.to_i(2), "Element was different than expected: #{element_number} != #{n_index} in base 2")
			end

		end

		def test_get_leaf_index_raises_error_for_bad_input

			bad_input = @prover.universe_size_m + 1

			assert_raises(RangeError){
				@prover.get_leaf_index(bad_input)
			}
		end
	end # describe get leaf index

	describe "range" do
		def test_range_of_self
			# Range of leaf is just itself
			expected_length_of_leaf_indices = @prover.bits_needed_for_leaves

			all_nodes = set_of_all_node_indices(@prover)
			all_nodes.each do |node_index|
				if node_index.length < expected_length_of_leaf_indices
					# We only want to assert for leaf nodes
				else
					# Have a leaf index
					actual_range = @prover.range(node_index)
					assert(actual_range.include?(node_index), "#{node_index} wasn't in #{actual_range}")

					# Leaf was the only element in the range
					assert(actual_range.size == 1, "Range had more than just leaf_node")
				end

			end

		end

		def test_range_returns_indices_of_correct_length
			num_bits_needed = @prover.bits_needed_for_leaves

			act_range = @prover.range('0')

			act_range.each do |leaf|
				assert_equal(num_bits_needed, leaf.length, "Leaf length is: #{leaf.length}")
			end
		end

		def test_range_of_root_is_whole_universe
			act_range = @prover.range('0')
			assert_equal(@prover.universe_size_m, act_range.length, "Range size is: #{act_range.length}")
		end

		def test_range_of_internal_node
			leaf_length = @prover.bits_needed_for_leaves
			all_node_indicies = set_of_all_node_indices(@prover)
			internal_nodes = all_node_indicies.reject {|ele| ele.length == leaf_length || ele.length == 1  }
			internal_nodes.each do |internal_node|
				extra_bits_needed = leaf_length - internal_node.length
				act_range = @prover.range(internal_node)
				expected_num_of_nodes_in_range = 2 ** extra_bits_needed
				assert_equal(expected_num_of_nodes_in_range, act_range.length, " Range of :#{internal_node} had the size: #{act_range.length} ")
			end

		end
	end # describe range

	describe "node digest" do
		def test_node_digest_is_correct_type_and_size

			@prover.addElement(0)
			zeroth_digest = @prover.node_digest( @prover.get_leaf_index(0) )

			zeroth_digest.must_be_instance_of Vector
			assert_equal(@prover.k, zeroth_digest.size, "Digest Row Size is: #{zeroth_digest.size}")
		end

		def test_node_digest_in_Z_q
			addSomeElements(@prover, 10)

			all_nodes = set_of_all_node_indices(@prover)
			all_nodes.each do |node_index|
				digest = @prover.node_digest(node_index)

				digest.each do |ele|
					assert(ele < @prover.q, "Element: #{ele} was expected to be less than #{@prover.q}")
				end
			end
		end
	end # describe node digest

	describe "node label" do

		def test_node_label_is_correct_type_and_size

			@prover.addElement(0)
			zeroth_label = @prover.node_label( @prover.get_leaf_index(0) )

			zeroth_label.must_be_instance_of Vector
			assert_equal(@prover.k * @prover.log_q_ceil, zeroth_label.size, "Label Size is: #{zeroth_label.size}")
		end


		def test_node_label_in_Z_q
			addSomeElements(@prover, 20)

			all_nodes = set_of_all_node_indices(@prover)
			all_nodes.each do |node_index|
				label = @prover.node_label(node_index)

				label.each do |ele|
					assert(ele < @prover.q, "Element: #{ele} was expected to be less than #{@prover.q}")
				end
			end

		end
	end # describe node label

	describe "binary with num bits" do
		def test_binary_with_num_bits
			expected = '000'
			actual = @prover.binary_with_num_bits(0, 3)
			assert_equal(expected, actual)

			expected = '100'
			actual = @prover.binary_with_num_bits(4, 3)
			assert_equal(expected, actual)

			expected = '101'
			actual = @prover.binary_with_num_bits(5, 3)
			assert_equal(expected, actual)

			expected = '111'
			actual = @prover.binary_with_num_bits(7, 3)
			assert_equal(expected, actual)
		end

		def test_raises_error_for_intergers_too_big
			assert_raises(ArgumentError){
				@prover.binary_with_num_bits(100, 4)
			}
		end
	end # describe binary with num bits

	describe "update path" do

		def test_get_update_path_does_not_include_root
			update_path = @prover.get_update_path( @prover.get_leaf_index(0) )

			update_path.wont_include '0'
		end


		def test_get_update_path_has_correct_number_of_node_indices
			update_path = @prover.get_update_path( @prover.get_leaf_index(0) )

			# Expect one less than num bits needed (root is not on update path)
			expected_length = @prover.bits_needed_for_leaves - 1

			assert_equal(expected_length, update_path.length, "Update path had #{update_path.length} elements.")
		end

		def test_update_path_order
			leaf_indices = set_of_leaf_indices(@prover)

			leaf_indices.each do |idx|
				update_path  = @prover.get_update_path(idx)

				(update_path.length - 1).times do |i|
					assert( update_path[i].length == update_path[i + 1].size + 1, "update path: #{update_path}")
				end
			end

		end
	end # describe update path

	describe "siblings (membership proof)" do

		def test_siblings_correct_length

			# TODO Test all the leaves
			siblings_labels = @prover.get_membership_proof( @prover.get_leaf_index(1) )
			tree_depth = @prover.bits_needed_for_leaves

			assert_equal(tree_depth - 1, siblings_labels.length, "Proof had #{siblings_labels.length} elements. #{tree_depth - 1} expected")
		end

		def test_siblings_is_list_of_pairs
			leaf_index = @prover.get_leaf_index(1)

			siblings_labels = @prover.get_membership_proof( leaf_index )

			update_path = @prover.get_update_path leaf_index

			update_path.each_with_index do |node_index, i|

				label1 = @prover.node_label node_index
				label2 = @prover.node_label @prover.sibling(node_index)

				child_label1, child_label2 = siblings_labels[i]

				assert_equal(label1, child_label1)
				assert_equal(label2, child_label2)
			end
		end

		# def test_order_of_pairs
		# 	leaf_indices = set_of_leaf_indices(@prover.universe_size_m, @prover.bits_needed_for_leaves)

		# 	leaf_indices.each do |leaf_index|
		# 		siblings_labels = @prover.get_membership_proof leaf_index

		# 		parent(leaf_index)
		# 	end

		# end
	end # describe siblings

	describe "cover" do
		def test_raise_error_for_elements_out_of_range
			assert_raises(RangeError){
				@prover.cover(0...@prover.universe_size_m + 1)
			}

			assert_raises(RangeError){
				@prover.cover(-1...@prover.universe_size_m)
			}

			assert_raises(RangeError){
				@prover.cover(-1, 1)
			}

			assert_raises(RangeError){
				@prover.cover(0, @prover.universe_size_m + 1)
			}

			#Doesn't raise hack.
			assert(@prover.cover(0...@prover.universe_size_m).is_a? Object)
		end

		def test_cover_of_single_index

			element_number = rand(@prover.universe_size_m)
			leaf_index     = @prover.get_leaf_index( element_number )
			cover          = @prover.cover(element_number)

			assert_equal(1, cover.size, "Cover not the right size")
			assert(cover.include?(leaf_index), "Cover: #{cover} did not include #{leaf_index}")
		end

		def test_cover_of_two_with_same_parent_is_parent

			cover      = @prover.cover(0, 1)
			leaf_index = @prover.get_leaf_index 0
			parent     = @prover.parent leaf_index

			assert_equal(1, cover.size, "Cover: #{cover} not the right size")
			assert( cover.include?(parent), "Cover: #{cover} did not include #{parent}")
		end

		def test_cover_of_two_adjacent_leaves_with_different_parents

			cover        = @prover.cover(1, 2)
			leaf_index_0 = @prover.get_leaf_index 1
			leaf_index_1 = @prover.get_leaf_index 2

			assert_equal(2, cover.size, "Cover: #{cover} not the right size")
			assert( cover.include?(leaf_index_0), "Cover: #{cover} did not include #{leaf_index_0}")
			assert( cover.include?(leaf_index_1), "Cover: #{cover} did not include #{leaf_index_1}")
		end

		def test_cover_of_universe_is_root
			cover = @prover.cover(0, @prover.universe_size_m - 1)

			assert(cover.include?('0'), "Cover: #{cover} should include root")
			assert_equal(1, cover.size, "Cover: #{cover} should only include root element")

		end
	end # describe cover

	describe "range proof" do
		def test_range_proof_attributes
			addSomeElements(@prover, 10)

			proof = @prover.get_range_proof(0...@prover.universe_size_m)

			proof.each do |ele|
			end
			skip "Not implemented"
		end
	end # describe range proof

	describe "correctness conditions" do

		describe "check radix int/label" do

			it "should raise an error if the dimensions are incorrect" do

				label  = [1,2,3]
				digest = [1,2,3]

				assert_raises(TypeError){
					@prover.check_radix_label(label, digest)
				}
			end
		end #describe check radix

		def test_digest_is_radix_of_label

			addSomeElements(@prover, 9)

			all_nodes = set_of_all_node_indices(@prover)
			all_nodes.each do |node|
				digest = @prover.node_digest(node)
				label = @prover.calc_node_label(node)

				puts "Checking label: #{label}"
				puts "Checking digest: #{digest}"
				puts "q : #{@prover.q}"

				assert(@prover.check_radix_label(label, digest), "Label/Digest Relation Failed for node: #{node}")
			end
		end

		def test_digest_is_hash_of_child_labels

			addSomeElements(@prover, 9)


			all_nodes = set_of_all_node_indices(@prover)
			internal_nodes = all_nodes.reject {|ele| ele.length == @prover.bits_needed_for_leaves }

			internal_nodes.each do |internal_node|
				calculated_digest = @prover.node_digest(internal_node)

				hashed_digest = @prover.hash(internal_node + '0' , internal_node + '1')
				assert_equal(calculated_digest, hashed_digest, "Hashed digest did not equal caclulated digest.")
			end
		end
	end # describe correctness conditions

end # describe
end # TestProver