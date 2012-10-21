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
		# Put feature tests here

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
	end # describe instance fields


	
end # describe Sads