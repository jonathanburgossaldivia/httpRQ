#!/usr/bin/ruby

require 'benchmark'
require 'net/http'
require 'uri'
require 'timeout'
require 'optparse'

system "clear"

options = {}

OptionParser.new do |opts|
	opts.banner = "\n Usage: ruby httpRQ.rb [options] [arguments...]\n"+
	" Example: ruby httpRQ.rb -u http://www.example.com -r5 -w1 , you should always put 'http://'"
	opts.separator ""
	opts.version = "0.1"
	opts.on('-r', '--repeat nTIMES', 'Repeat n times, default value is 10.') do |nveces|
		options[:nveces] = nveces;
	end
	opts.on('-w', '--waith nSECONDS', 'Wait n seconds, default value is 0.') do |wseconds|
		options[:wseconds] = wseconds;
	end
	opts.on('-u', '--url URL', 'Measure response time HTTP Request of certain url.') do |url|
		options[:url] = url;
	end
	begin
		opts.parse!
	rescue OptionParser::ParseError => error
		print "\n [!] #{error}\n [!] -h or --help to show valid options.\n\n"
		exit 1
	end
end

nveces = options[:nveces].to_i
if nveces == 0
	nveces = 10
end

url = options[:url]
if url == nil
	print "\n [!] -h or --help to show valid options.\n\n"
	exit 1
end

wseconds = options[:wseconds].to_i
if wseconds == 0
	wseconds = 0
end

begin
	Benchmark.realtime {Timeout::timeout(5){Net::HTTP.get_response(URI.parse(url))}}
rescue Timeout::Error, Errno::ECONNREFUSED, SocketError, Errno::ENETDOWN => error
	puts
	puts " [!] Connection refused, invalid url format or unreachable Host, -h or --help to show valid options."
	puts
	exit 1
end

print "\n httpRQ by Jonathan Burgos Saldivia > \n\n"

total = 0

(1..nveces.to_i).each do |n|

	begin
		tiempo = Benchmark.realtime {Timeout::timeout(3){Net::HTTP.get_response(URI.parse(url))}}.round(5)
	rescue Timeout::Error, Errno::ECONNREFUSED, SocketError, Errno::ENETDOWN => error
		print " [!] Request #{n}: connection refused.\n"
			else
		print " [+] Request #{n}: #{tiempo} seconds.\n"
		total += tiempo
		sleep wseconds
	end

end

puts "\n [!] Average for #{url} : #{(total / nveces.to_i).round(5)} seconds. \n\n"