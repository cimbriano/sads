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

	# describe "verify_membership_proof" do
	# 	before do
	# 		@prover = Prover.new(5,10,8)
	# 	end

	# 	def test_prover_is_not_nil
	# 		assert(!@prover.nil?, "Prover was nil.")
	# 	end

	# 	def test_membership_proof
	# 		puts "Test Membership proof"

	# 		puts "Prover: #{@prover}"
	# 		addSomeElements(@prover, 8)

	# 		# TODO Test all the leaves
	# 		leaves = set_of_leaf_indices(@prover)

	# 		proof = @prover.get_membership_proof( @prover.get_leaf_index(1) )

	# 		assert( @ver.verify_membership_proof(proof) , "Proof does not check out")
	# 	end
	# end # describe verification



	# describe "verify range proof" do
	# 	def test_correctness

	# 		puts "test correctness"
	# 		puts "prover: #{@prover}"
	# 		addSomeElements(@prover, 10)

	# 		puts "added Elements"

	# 		proof = @prover.get_range_proof(0...@prover.universe_size_m)

	# 		assert(@ver.verify_range_proof(proof), "Proof failed verification")
	# 	end
	# end # describe verify range proof


end # describe verifier
end # TestVerifier