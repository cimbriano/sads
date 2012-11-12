require 'helper'
require 'sads_helper'
require 'prime'

class TestSads < MiniTest::Unit::TestCase

	def setup
		@sad = Sads.new(2,10, 8)
	end

	def test_constructor
		@sad.wont_be_nil
	end

	def test_mu_is_not_a_float
		# primes = Prime.instance
		# primes = [2,3,5,7,11,13,17,19,23,29]

		Prime.each (100) do |q|

			(1..10).each do |k|

				@sad.calculate_mu(k, q).must_be_instance_of Fixnum
			end
		end
	end

	def test_calc_q

		# assert_true( calculate_q(1024, 256)
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

	def test_hash_result_is_a_matrix
		m = @sad.mu / 2

		x = column_vector(m)
		y = column_vector(m)

		assert_instance_of(Matrix, @sad.hash(x,y))
	end

	def test_hash_elements_are_mod_q

		m = @sad.mu / 2
		max = @sad.q * 4

		x = column_vector_with_max(m, max)
		y = column_vector_with_max(m, max)

		@sad.hash(x,y).each do |item|
			assert(item < @sad.q, "#{item} is >= #{@sad.q}")
		end
	end

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

	def test_partial_digest_wrt_itself
		# Digest of a node with respect to istelf should be a vector of 1

		# TODO - Test all elements in universe
		leaf_index = @sad.get_leaf_index(7)
		part_dig = @sad.partial_digest(leaf_index, leaf_index)

		part_dig.must_be_instance_of Vector
		assert_equal(@sad.k, part_dig.size, "Partial Digest rowsize: #{part_dig.size}")
	end

	def test_partial_digest_wrt_leaf_node
		skip
	end


	def test_node_digest_is_correct_type_and_size

		@sad.addElement(0)
		@sad.addElement(1)
		@sad.addElement(1)
		@sad.addElement(3)
		@sad.addElement(6)
		@sad.addElement(7)
		@sad.addElement(7)
		@sad.addElement(7)

		zeroth_digest = @sad.node_digest('0000')

		zeroth_digest.must_be_instance_of Vector

		assert_equal(@sad.k, zeroth_digest.size, "Digest Row Size is: #{zeroth_digest.size}")
		# assert_equal(1, zeroth_digest.column_size, "Digest column size is: #{zeroth_digest.column_size}")

		zeroth_digest.each do |ele|
			assert_equal(1, ele, "Element was #{ele}, not 1 as expected")
		end

		seventh_digest = @sad.node_digest('0111')
		seventh_digest.each do |ele|
			assert_equal(3, ele, "Element was #{ele}, not 3 as expected")
		end
	end

	def test_partial_label
		skip
	end

	def test_node_label
		skip
	end

	def test_range_of_self
		# Range of leaf is just itself
		expected_length_of_leaf_indices = @sad.bits_needed_for_leaves

		all_nodes = set_of_all_node_indices(@sad.universe_size_m)

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
		skip
	end

	def test_mod
		m = Matrix.build(10, 10) { rand 100 }

		mod(m, 8).each do |ele|

			assert(ele < 8)
		end
	end

	def test_digest_is_radix_of_label
		skip
		all_nodes = set_of_all_node_indices(@sad.universe_size_m)

		all_nodes.each do |node|
			digest = @sad.node_digest(node)
			label = @sad.node_label(node)
			assert(check_radix_label(label, digest, @sad.q), "Label/Digest Relation Failed for node: #{node}")
		end
	end

	def test_get_leaf_index
		bit_length = @sad.log_q_ceil + 1

		(0...@sad.universe_size_m).each do |element_number|
			n_index = @sad.get_leaf_index(element_number)
			assert_equal(bit_length, n_index.length, "node_index was not the expected length. Node: #{element_number} had index #{n_index}")
		end

	end

	def test_get_leaf_index_raises_error_for_bad_input

		bad_input = @sad.universe_size_m + 1

		assert_raises(RangeError){
			@sad.get_leaf_index(bad_input)
		}
	end

	def test_get_update_path_has_correct_number_of_node_indices
		skip
	end

	def test_get_update_path_does_not_include_root
		skip
		# @sad.update_path('')
	end

	def test_binary_with_log_q_bits
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





end # TestSads
