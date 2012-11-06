require 'helper'
require 'sads_helper'
require 'prime'

class TestSads < MiniTest::Unit::TestCase

	def setup
		@sad = Sads.new(2,10)
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
		m = @sad.mu / 2

		x = column_vector(@sad.k)

		# puts
		# puts "k: #{@sad.k}"
		# puts "q: #{@sad.q}"
		# puts "log q: #{Math.log2(@sad.q).ceil}"

		b_size = @sad.binary_vector(x).row_size
		expected = @sad.k * Math.log2(@sad.q).ceil

		assert_equal(	expected, b_size)

	end


end
