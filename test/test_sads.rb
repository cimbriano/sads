require 'helper'
require 'sads_helper'
require 'prime'

class TestSads < MiniTest::Unit::TestCase

	describe "Sads" do

		before do
			@sad = Sads.new(5,10,8)
		end

		describe "hash function" do

			def test_hash_raises_error_for_unlike_types
				assert_raises(TypeError){
					@sad.hash('00', 0)
				}
			end

			def test_hash_raises_error_for_similar_types_not_string_or_vector
				assert_raises(TypeError){
					@sad.hash(0,0)
				}
			end

			def test_hash_result_is_a_vector
				m = @sad.mu / 2

				x = column_vector(m)
				y = column_vector(m)

				assert_instance_of(Vector, @sad.hash(x, y, false))
			end

			def test_hash_elements_are_mod_q
				m = @sad.mu / 2
				max = @sad.q * 4

				x = column_vector_with_max(m, max)
				y = column_vector_with_max(m, max)

				@sad.hash(x, y, false).each do |item|
					assert(item < @sad.q, "#{item} is >= #{@sad.q}")
				end
			end

			def test_hash_of_vectors_fails_without_parameter
				m = @sad.mu / 2

				v1 = column_vector(m)
				v2 = column_vector(m)

				assert_raises(ArgumentError){
					@sad.hash(v1,v2)
				}
			end

			def test_hash_of_string_checks_order

				zeroth = @sad.get_leaf_index(0)
				first  = @sad.get_leaf_index(1)

				assert_equal(@sad.hash(zeroth, first), @sad.hash(first, zeroth), "Hash of siblings (x,y) not equal to hash of (y,x)")
			end
		end # describe hash function

		describe "binary vector" do
			def test_binary_vector
				x = column_vector(@sad.k)

				b_vector = @sad.binary_vector(x)

				b_vector.must_be_instance_of Vector

				size = b_vector.size
				# b_columnsize = b_vector.column_size

				# m = k * log q
				expected_size = @sad.k * @sad.log_q_ceil


				assert_equal(expected_size, size, "Row size is #{size}")
				# assert_equal(1 ,b_columnsize, "Column size is: #{b_columnsize}")
			end
		end # describe binary vector

		describe "partial digest" do

			def test_partial_digest_wrt_itself
				# Digest of a node with respect to istelf should be a vector of 1

				# TODO - Test all elements in universe
				leaf_index = @sad.get_leaf_index(1)
				part_dig = @sad.partial_digest(leaf_index, leaf_index)

				part_dig.must_be_instance_of Vector
				assert_equal(@sad.k, part_dig.size, "Partial Digest rowsize: #{part_dig.size}")

				part_dig.each do |element|
					assert_equal(1, element, "Element of partial digest was #{element}")
				end
			end

			# def test_partial_digest_wrt_leaf_node

			# 	skip "Not sure how to test the application of L and R matrices"
			# 	# l_matrix = @sad.L
			# 	# r_matrix = @sad.R

			# 	# pd_00_3 = @sad.partial_digest(@sad.get_leaf_index(3), '00')
			# 	# puts "Partial Digest Calculated"

			# 	# unpacked_vector = l_matrix.inverse * pd_00_3

			# 	# unpacked_vector.each do |ele|
			# 	# 	assert_equal(1, ele, "Unpakced vector element was #{ele}")
			# 	# end

			# 	# pd_01_4 = @sad.partial_digest(@sad.get_leaf_index(4), '01')
			# end

			def test_partial_digest_in_Z_q

				addSomeElements(@sad, 10)

				all_nodes = set_of_all_node_indices(@sad)
				begin
					all_nodes.each do |node_index|

						# puts "Node_index: #{node_index}"

						leaf_range = @sad.range(node_index)

						leaf_range.each do |leaf|

							# puts "Leaf: #{leaf}"

							p_dig = @sad.partial_digest(node_index, leaf)

							p_dig.each do |ele|
								assert(ele < @sad.q, "Element was greater than q: #{ele}")
							end
						end
					end

				rescue ArgumentError => err
					puts err
					fail
				end
			end
		end # describe partial digest

		describe "partial label" do

			def test_partial_label_size
				begin
					p_label = @sad.partial_label('01', '0110')
					assert_equal(@sad.k * @sad.log_q_ceil, p_label.size, "Size of p_label was #{p_label.size}")
				rescue ArgumentError => err

					puts err.backtrace
					puts "Error Message"

				end
			end
		end # describe partial label

		describe "sads util methods" do
			describe "mod" do
				def test_mod
					m = Matrix.build(10, 10) { rand 100 }

					mod(m, 8).each do |ele|
						assert(ele < 8)
					end

				end
			end #describe mod

			describe "check radix int/label" do

				it "should raise an error if the dimensions are incorrect" do

					label  = [1,2,3]
					digest = [1,2,3]

					assert_raises(TypeError){
						@sad.check_radix_label(label, digest)
					}
				end
			end #describe check radix

			def test_right_child
				all_nodes = set_of_all_node_indices(@sad)
				all_nodes.each do |node|
					assert_equal(node[-1] == '1', @sad.right_child?(node), "#{node} is a left child")
				end
			end

			describe "frequency table" do

				def test_table_for_leaf_only_includes_leaf
					@sad.addElement 0
					leaf            = @sad.get_leaf_index 0
					frequency_table = @sad.get_frequency_table(leaf)

					assert_equal( 1, frequency_table.size, "Freq table size incorrect.")
					assert( frequency_table.include?(leaf), "Leaf not included in its own freq table")
					assert_equal( @sad.leaves[leaf], frequency_table[leaf], "Wrong frequncy returned")
				end

				def test_table_for_root_include_all_leaves
					all_leaves      = set_of_leaf_indices(@sad)


					(0...@sad.universe_size_m).each do |ele|
						@sad.addElement ele
					end

					frequency_table = @sad.get_frequency_table('0')
					assert_equal(all_leaves.size, frequency_table.size, "Freq table did not include all leaves")
				end



			end # describe frequency table
		end # describe helper methods

		describe "test helper methods" do
			def test_all_set_of_all_nodes
				num_leaves = @sad.universe_size_m
				expected_nodes = 2 * num_leaves - 1

				nodes = set_of_all_node_indices(@sad)

				assert_equal(expected_nodes, nodes.size, "Set of nodes was incorrect size: #{nodes}")
			end

			def test_set_of_all_leaves
				leaves = set_of_leaf_indices(@sad).size
				assert_equal(@sad.universe_size_m, leaves, "Set of leaves not right size: #{leaves}")
			end
		end # describe

		describe "correctness conditions" do

			def test_digest_is_radix_of_label

				assert(@sad.leaves.empty?, "Sads leaves is not empty: #{@sad.inspect}")
				addSomeElements(@sad, 9)

				all_nodes = set_of_all_node_indices(@sad)
				all_nodes.each do |node|
					digest = @sad.node_digest(node)
					label = @sad.node_label(node)


					# puts "Checking label: #{label}"
					# puts "Checking digest: #{digest}"
					# puts "q : #{@sad.q}"

					assert(@sad.check_radix_label(label, digest), "Label/Digest Relation Failed for node: #{node}")
				end
			end

			def test_digest_is_hash_of_child_labels

				assert(@sad.leaves.empty?, "Sads leaves is not empty: #{@sad.inspect}")
				addSomeElements(@sad, 9)


				all_nodes = set_of_all_node_indices(@sad)
				internal_nodes = all_nodes.reject {|ele| ele.length == @sad.bits_needed_for_leaves }

				internal_nodes.each do |internal_node|
					calculated_digest = @sad.node_digest(internal_node)

					hashed_digest = @sad.hash(internal_node + '0' , internal_node + '1')
					assert_equal(calculated_digest, hashed_digest, "Hashed digest did not equal caclulated digest.")
				end
			end
		end # describe correctness conditions

	end # describe Streaming Authenticated Data Structure
end # TestSads
