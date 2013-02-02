require 'benchmark'
require 'prover'
require 'verifier'

puts "Benchmarking time to instantiate the prover"

[50].each do |k|
	puts "k: #{k}"

	(10_000..10_000).step(10000) do |n|
		puts "Stream Size: #{n}"

		(100..1000).step(100) do |m|
			puts "Universe Size: #{m}"


			Benchmark.bmbm do |x|
				x.report("k:#{k}, n:#{n}, m:#{m}") {
					p = Prover.new(k, n, m)
					p = nil
				}
			end

		end # m
	end # n
end # k
