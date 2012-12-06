require 'helper'
require 'sads_helper'
require 'verifier'

class TestVerifier < MiniTest::Unit::TestCase

describe "Verifier" do

	before do
		@ver = Verifier.new(1,2,3,4,5,6,8)
	end

	def test_constructor
		assert(!@ver.nil?, "Verifier not constructed")
	end

	def test_mod
		ans = @ver.send(:mod, 8, 2)
		assert_equal(0, ans, "Mod not working")
	end

	def test_has_correct_fields
		assert(@ver.respond_to?(:L))
		assert(@ver.respond_to?(:R))
		assert(@ver.respond_to?(:root_digest))
	end


	describe "verify_membership_proof" do
		before do
			@p = Prover.new(5,10,8)
			@v = Verifier.new(@p.k, @p.stream_bound_n, @p.q, @p.log_q_ceil, @p.L, @p.R, @p.universe_size_m)
		end

		def test_prover_is_not_nil
			assert(!@p.nil?, "Prover was nil.")
		end

		def test_membership_proof
			addSomeElements(@p, 8)


			# TODO Test all the leaves
			# leaves = set_of_leaf_indices(@p)
			proof = @p.get_membership_proof( @p.get_leaf_index(1) )


			assert( @v.verify_membership_proof(proof) , "Proof does not check out")
		end
	end # describe verification

	describe "verify range proof" do
		before do
			@p = Prover.new(5,10,8)
			@v = Verifier.new(@p.k, @p.stream_bound_n, @p.q, @p.log_q_ceil, @p.L, @p.R, @p.universe_size_m)
		end

		def test_correctness
			addSomeElements(@p, 10)
			proof = @p.get_range_proof(0...@p.universe_size_m)

			assert(@v.verify_range_proof(proof), "Proof failed verification")
		end
	end # describe verify range proof




end # describe verifier
end # TestVerifier