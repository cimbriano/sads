require 'benchmark'
require 'prover'
require 'verifier'

puts "Benchmarking time to update the prover with a new 'stream' element"


[50].each do |k|
	puts "k: #{k}"
	(100..100).step(1) do |n|
		puts "Stream Size: #{n}"
		(100..100).step(1) do |m|
			puts "Universe Size: #{m}"

			p = nil
			puts "Time to Instantiate Prover"
			puts Benchmark.measure { p = Prover.new(k, n, m) }


			# v = Verifier.new(p.k, p.stream_bound_n, p.q, p.log_q_ceil, p.L, p.R, p.universe_size_m)

			# Pre-generate random elements to add to the prover
			num_elements_to_add = 100
			elements = Array.new(num_elements_to_add){ rand(p.universe_size_m) }

			# Obtain references to provers internal objects
			labels = p.labels
			p_labels = p.partial_labels
			leaves = p.leaves

			Benchmark.bmbm do |x|

				x.report("k:#{k}, n:#{n}, m:#{m}, ele added:#{num_elements_to_add}") {
					(0...num_elements_to_add).each do |index|
						p.addElement(elements[index])
					end
				}

				# Reset prover storage, outside of report
				labels.clear
				p_labels.clear
				leaves.clear
			end

		end # m
	end # n
end # k

