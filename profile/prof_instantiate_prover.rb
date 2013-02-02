require 'optparse'
require 'prover'

# opts = {}


# opt_parser = OptionParser.new do |opt|
#   # opt.banner = "Usage: opt_parser COMMAND [OPTIONS]"

#   opt.on("-k","--security-parameter PARAM", Numeric, "Security parameter") do |k|
#     opts[:k] = k
#   end

#   opt.on("-n","--stream-size SIZE", Numeric, "Upper bound on length of stream") do |n|
#     opts[:n] = n
#   end

#   opt.on("-m","--universe-size SIZE", Numeric, "Size of universe of elements") do |m|
#     opts[:m] = m
#   end

#   opt.on("-h","--help","help") do
#     puts opt_parser
#   end

# end

# opt_parser.parse!

# puts "Opts: k=#{opts[:k]}, n=#{opts[:n]}, m=#{opts[:m]}"

# p = Prover.new(opts[:k], opts[:n], opts[:m])

p = Prover.new(10, 10, 10)