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
		assert_equal(12, @sad.calculate_mu(2,8))
		assert_equal(16, @sad.calculate_mu(2,9))
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
		skip
		# m = @sad.mu / 2

		# x = column_vector(m)
		# y = column_vector(m)

		# @sad.hash(x,y).each do |item|
		# 	assert(item < @sad.q, "#{item} is >= #{@sad.q}")
		# end
	end

	def test_binary_vector
		x = column_vector(@sad.k)

		b_vector = @sad.binary_vector(x)



		b_rowsize = b_vector.row_size
		b_columnsize = b_vector.column_size

		# m = k * log q
		expected_row_size = @sad.k * Math.log2(@sad.q).ceil


		assert_equal(expected_row_size, b_rowsize, "Row size is #{b_rowsize}")
		assert_equal(1 ,b_columnsize, "Column size is: #{b_columnsize}")
	end

	def test_partial_digest_wrt_itself
		# Digest of a node with respect to istelf should be a vector of 1
		#
		part_dig = @sad.partial_digest('00', '00')

		part_dig.must_be_instance_of Matrix
		assert_equal(@sad.k, part_dig.row_size, "Partial Digest rowsize: #{part_dig.row_size}")
		assert_equal(1, part_dig.column_size, "Partial Digest Column Size: #{part_dig.column_size}")
	end

	def test_partial_digest_wrt_leaf_node

		s = ['00','000']

		s.each do |internal_node|
			# puts internal_node
			part_dig = @sad.partial_digest('0', internal_node)
			part_dig.must_be_instance_of Matrix
			assert_equal(@sad.k, part_dig.row_size, "Partial Digest wrt #{internal_node} rowsize: #{part_dig.row_size}")
			assert_equal(1, part_dig.column_size, "Partial Digest wrt #{internal_node} Column Size: #{part_dig.column_size}")
	end



	end

	def test_partial_label

	end

	def test_node_digest

	end

	def test_node_label

	end

	def test_range_of_self
		# Range of leaf is just itself

		num_bits_needed = Math.log2(@sad.universe_size_m).ceil + 1
		# puts "Bits Needed: #{num_bits_needed}"

		leaf_node = '0' * num_bits_needed
		# puts "Leaf node: #{leaf_node}"

		act_range = @sad.range(leaf_node)
		# puts "Returned range: #{act_range}"

		assert(act_range.include?(leaf_node), "Leaf node is not in range of iteself")

		# Remove leaf_node
		act_range.delete(leaf_node)

		assert(act_range.empty?, "Range had more than just leaf_node")
	end

	def test_range_returns_indices_of_correct_length
		num_bits_needed = Math.log2(@sad.universe_size_m).ceil + 1

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


end
