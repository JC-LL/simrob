require "optparse"

module Simrob

  class Runner
    def self.run *arguments
      new.run(arguments)
    end

    def run arguments
      begin
        options = parse_options(arguments)
        if filename=options[:file]
          params_h=eval(IO.read(filename))
          params_h[:boot_vm]=options[:boot_vm]
          simulator=Simulator.new(params_h)
          simulator.start
        else
          puts "need a scenario file : simrob [options] <file>"
          abort
        end
      rescue Exception => e
        puts e
        puts e.backtrace
      end
      return true
    end

    def header
      puts "simrob (#{VERSION}) - ENSTA Bretagne 2022"
    end

    private
    def parse_options(arguments)
      options = {}
      empty=arguments.empty?
      parser=OptionParser.new do |opts|
        opts.banner = "Usage: example.rb [options]"

        opts.on("-v", "--version", "print version number") do |v|
          puts VERSION
          exit(true)
        end
        opts.on("-h", "--help", "show help message") do
          puts opts
          abort
        end
        opts.on("-b", "--boot_vms", "boot Robots VM") do
          options[:boot_vm]=true
        end
        opts.on("-s FILE", "--scenario FILE", "load a scenario") do |name|
          options[:file]=name
        end
      end
      puts parser if empty
      parser.parse!(arguments)
      options
    end
  end
end
