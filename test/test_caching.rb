require 'helper'
require 'prover'

class TestCaching < MiniTest::Unit::TestCase

describe "Caching Behavior of Partial Labels" do
	before do
		@prover = Prover.new(5,10,8)
	end

	describe "Default Instantiation" do
		def test_partial_label_storage_exists
			@prover.partial_labels.wont_be_nil
		end

		def test_partial_label_storage_is_empty
			@prover.partial_labels.empty?
		end
	end # Default Instantiation

	describe "Calculating New Partial Labels" do
		def test_new_partial_labels_are_added_to_storage
			storage = @prover.partial_labels
			assert( storage.empty? )

			random_element = rand(@prover.universe_size_m)

			calculated_elements = @prover.get_update_path( @prover.get_leaf_index(random_element) )

			@prover.addElement( random_element )

			calculated_elements.each do |ele|
				assert( storage.include? ele )
			end


		end

	end # describe

end # main describe

end # TestCaching