require "graphics"

module Simrob

  class Simulator < Graphics::Simulation

    attr_accessor :robots, :scenario

    def initialize scenario_h
      @scenario=scenario_h
      dims=@scenario[:field_dims] || [800,600]
      super(*dims)
    end

    def start
      elaborate
      handle_vm_s
      run
    end

    def elaborate
      @robots=scenario[:robots].map{|params_h| Robot.new(params_h)}
      # also each robot knows the limits of the field :
      @robots.each{|rob| rob.field_dims=@scenario[:field_dims]}
      register_bodies @robots
    end

    def handle_vm_s
      boot_vm if @scenario[:boot_vm]
    end

    def boot_vm
      robots.each(&:start_vm)
    end

    def update n
      robots.each(&:update)
    end

    # Simulation#draw automatically calls Robot::View.draw on all robots.
    def draw n
      super
      fps n
    end
  end
end
