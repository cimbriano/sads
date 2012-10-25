# sads_spec.rb
require 'sads'

describe Sads do

	it "should be a sads object" do
		Sads.new.should be_a(Sads)
	end
	
	before(:each) do
		# Pre-test setup
		@sad = Sads.new()
	end

	describe "instance fields" do

		it "should have a structure called labels" do
			@sad.should respond_to(:labels)
		end

		it "should have L (left) and R (right) matrices (or column vectors)" do
			@sad.should respond_to(:L)
			@sad.should respond_to(:R)
		end

		it "should have a public and secret keypair" do
			@sad.should respond_to(:pubkey)
		end

		it "should have a field called leaves" do
			@sad.should respond_to(:leaves)
		end

		it "should have a field called digest" do
			@sad.should respond_to(:digest)
		end
	end # describe instance fields

	describe "initialize" do

		it "should initialize labels as a map" do
			@sad.labels.should be_empty
		end

		it "should initialize leaves as a map" do
			@sad.leaves.should be_empty
		end

		it "should initialize digest as a SOMETHING" do
			# @sad.digest.should_not be_nil
			pending
		end
	end # describe initialize

	describe "add element" do

		it "should update leaves table if the element is new" do
			@sad.addElement(1)
			@sad.leaves.should_not be_empty
		end

		it "should update the labels of the internal nodes on the path to the root" do
			pending
		end

		it "should update the digest of the tree" do
			pending
		end
	end # describe add element

	describe "remove element" do

		it "should update the leaves table if the element was in the tree" do
			@sad.addElement(1)
			@sad.removeElement(1)
			@sad.exists?(1).should be_false
		end

		it "should update the labels of the internal nodes on the path to the root" do
			pending
		end

		it "should update the digest of the tree" do
			pending
		end
	end # describe remove element

	describe "exists?" do

		it "should return true for elements in the tree" do
			@sad.addElement(1)
			@sad.exists?(1).should be_true
		end

		it "should return false for elements not in the tree" do
			@sad.addElement(1)
			@sad.exists?(2).should be_false
		end

		it "should return false for empty tree" do
			@sad.exists?(1).should be_false
		end
	end # describe 
end # describe Sads