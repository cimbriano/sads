# sads_spec.rb
require 'sads'

describe Sads do
	
	before(:each) do
		# Pre-test setup
		@sad = Sads.new()
	end

	describe "instance fields" do
		# Put feature tests here

		it "should have a structure called labels" do
			@sad.should respond_to(:labels)
		end

	end # describe some features


	
end # describe Sads