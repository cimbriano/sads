# sads_spec.rb
require 'spec/spec_helper'
require 'minitest/spec'
require 'minitest/autorun'

describe Sads do

	before(:all) do
		# Pre-test setup
		@sad = Sads.new(5,7)
	end

	it "should be a sads object" do
		@sad.must_be_instance_of Sads
	end

	describe "instance fields" do

		it "should have a structure called labels" do
			@sad.must_respond_to :labels
		end

		it "should have L (left) and R (right) matrices (or column vectors)" do
			@sad.must_respond_to :L
			@sad.must_respond_to :R
		end

		it "should have a public and secret keypair" do
			skip "Accessible via accessor so test isn't fragile w.r.t field name"
		end

		it "should have a field called leaves" do
			@sad.must_respond_to :leaves
		end

		it "should have a field called digest" do
			@sad.must_respond_to :digest
		end

		describe "L and R vectors" do

			it "should be a vector sized k * m and have elements in Z_q" do
				skip "Not implemented"
			end

		end #describe L and R vectors
	end # describe instance fields

	describe "initialize" do

		it "should initialize L vector" do
			@sad.L.size.must_be 10
			# pending "Needs specification"
		end

		it "should initialize R vector" do
			skip "Needs specification"
		end

		it "should initialize the public/secret keypair" do
			skip "Needs specification"
		end

		it "should initialize labels as a map" do
			@sad.labels.must_be :empty?
		end

		it "should initialize leaves as a map" do
			@sad.leaves.must_be :empty?
		end

		it "should initialize digest as a SOMETHING" do
			# @sad.digest.should_not be_nil
			skip
		end
	end # describe initialize

	# describe "add element" do

	# 	it "should update leaves table if the element is new" do
	# 		@sad.addElement(1)
	# 		@sad.leaves.should_not be_empty
	# 	end

	# 	it "should update the labels of the internal nodes on the path to the root" do
	# 		pending
	# 	end

	# 	it "should update the digest of the tree" do
	# 		pending
	# 	end
	# end # describe add element

	# describe "remove element" do

	# 	it "should update the leaves table if the element was in the tree" do
	# 		@sad.addElement(1)
	# 		@sad.removeElement(1)
	# 		@sad.exists?(1).should be_false
	# 	end

	# 	it "should update the labels of the internal nodes on the path to the root" do
	# 		pending
	# 	end

	# 	it "should update the root digest of the tree" do
	# 		pending
	# 	end
	# end # describe remove element

	# describe "exists?" do

	# 	it "should return true for elements in the tree" do
	# 		@sad.addElement(1)
	# 		@sad.exists?(1).should be_true
	# 	end

	# 	it "should return false for elements not in the tree" do
	# 		@sad.addElement(1)
	# 		@sad.exists?(2).should be_false
	# 	end

	# 	it "should return false for empty tree" do
	# 		@sad.exists?(1).should be_false
	# 	end
	# end # describe
end # describe Sads