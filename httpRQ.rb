#!/usr/bin/ruby

require 'benchmark'
require 'net/http'
require 'optparse'
require 'timeout'
require 'uri'

options = {}
OptionParser.new { |opts|
	opts.banner = "\n Usage: ruby httpRQ.rb [options] [arguments...]\n\n"+
	" Example: ruby httpRQ.rb -u http://www.example.com -r5 -w1 , you should always put 'http://'"
	opts.separator ""
	opts.version = "0.1"
	opts.on('-r', '--repeat nTIMES', 'Repeat n times, default value is 10.') { |nveces|
		options[:nveces] = nveces;}
	opts.on('-u', '--url URL', 'Measure response time HTTP Request of certain url.') { |url|
		options[:url] = url;}
	opts.on('-w', '--waith nSECONDS', "Wait n seconds, default value is 0.\n\n") { |wseconds|
		options[:wseconds] = wseconds;}
	begin
		opts.parse!
	rescue OptionParser::ParseError => error
		print "\n [!] #{error}\n [!] -h or --help to show valid options.\n\n"
		exit 1
	end
}

nveces = options[:nveces].to_i
nveces = 10 if nveces == 0

url = options[:url]
if url == nil
	print "\n [!] -h or --help to show valid options.\n\n"
	exit 1
end

wseconds = options[:wseconds].to_i
wseconds = 0 if options[:wseconds] == 0

begin
	Benchmark.realtime {Timeout::timeout(5){Net::HTTP.get_response(URI.parse(url))}}
rescue Timeout::Error, Errno::ECONNREFUSED, SocketError, Errno::ENETDOWN, Errno::ENETUNREACH => error
	print "\n [!] Connection refused: unreachable host or invalid url format, -h or --help to show valid options.\n\n"
	exit 1
end

print "\n httpRQ v0.1 by Jonathan Burgos Saldivia > \n\n"
puts " REQUEST".ljust(10) +" RESPONSE TIME".ljust(10) + "\n"

total = 0

(1..nveces).each { |n|
	begin
		tiempo = Benchmark.realtime {Timeout::timeout(3){Net::HTTP.get_response(URI.parse(url))}}.round(3)
	rescue Timeout::Error, Errno::ECONNREFUSED, SocketError, Errno::ENETDOWN, Errno::ENETUNREACH => error
		print " #{n}".ljust(10) +" connection refused".ljust(10) + "\n"
	else
		print " #{n}".ljust(10) +" #{tiempo}".ljust(7) + "seconds".rjust(7) + "\n"
		total += tiempo
		sleep wseconds
	end
}
puts "\n Average response time #{(total / nveces.to_i).round(4)} seconds for: #{url}\n\n"