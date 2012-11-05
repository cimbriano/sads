require 'helper'

class TestSads < MiniTest::Unit::TestCase
	def setup
		@sad = Sads.new
	end

	def test_constructor
		@sad.wont_be_nil
	end

	# Leave test here: failing test at the moment
	def test_calc_mu_q_0
		skip
		# assert(false, "Not implemented")
		# assert_equal(0, @sad.calculate_mu(0,0))
	end

	def test_mu_is_not_a_float
		skip
		# assert(false, "Not implemented")
	end

	def test_calc_q
		skip
		# assert(false, "Not implemented")
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

	def test_hash_elements_are_mod_q
		skip
		# @sad.hash(x,y).each do |item|
		# 	assert(item < @sad.q)
		# end
	end

	def test_hash_result_is_a_matrix
		skip
		# assert_instance_of(Matrix, @sad.hash(x,y))
	end

end
