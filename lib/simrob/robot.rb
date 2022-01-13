require "graphics"

include Math
D2R = PI / 180.0

module Simrob

  class Robot
    attr_accessor :name,:x,:y,:speed,:angle,:mag
    attr_accessor :field_dims, :params

    def initialize params_h
      @params  = params_h
      @name    = params_h[:name]
      @x,@y    = params_h[:pos]
      @angle   = params_h[:angle]
      @speed   = params_h[:speed]
      code     = params_h[:code]
      data     = params_h[:data]
      @vm      = Vm.new(self,code,data)
    end

    def start_vm
      @vm.boot
    end

    def update random=true
      read_actuators_from_dma if @vm.running
      @angle+=rand(-1..1)     if random
      update_pos
      if @vm.running
        @vm.step
        write_sensors_to_dma
        @vm.print_state
      end
    end

    def next_pos
      nx=@x+Math.cos(angle * D2R) * speed
      ny=@y+Math.sin(angle * D2R) * speed
      [nx,ny]
    end

    def update_pos
      nx,ny=next_pos()
      if nx> field_dims.first
        @angle=180-@angle
        nx,ny=next_pos()
      elsif nx<0
        @angle=180-@angle
      elsif ny> field_dims.last
        @angle=-@angle
        nx,ny=next_pos()
      elsif ny<0
        @angle=360-@angle
        nx,ny=next_pos()
      end
      @x,@y=nx,ny
    end

    def write_sensors_to_dma with_alea=false
      start_addr = @params[:base_shared_mem]
      addr_pos_x = start_addr + @params[:offset_sensor_x]
      addr_pos_y = start_addr + @params[:offset_sensor_x]
      addr_speed = start_addr + @params[:offset_sensor_speed]
      addr_angle = start_addr + @params[:offset_sensor_angle]
      @vm.ram_d[addr_pos_x] = @x      # NO ERROR wrt simulator
      @vm.ram_d[addr_pos_y] = @y      # NO ERROR wrt simulator
      @vm.ram_d[addr_speed] = @speed  # NO ERROR wrt simulator
      @vm.ram_d[addr_angle] = @angle  # NO ERROR wrt simulator
    end

    def read_actuators_from_dma with_alea=false
      start_addr = @params[:base_shared_mem]
      # Note :
      # - position x,y cannot be modified by VM
      # - speed and angle orders from VM operate instantaneously
      @params[:offset_actuor_speed]
      addr_speed = start_addr + @params[:offset_actuor_speed]
      addr_angle = start_addr + @params[:offset_actuor_angle]
      @speed     = ( @vm.ram_d[addr_speed] || @speed)
      @angle     = ( @vm.ram_d[addr_angle] || @angle)
    end

    class View
      def self.draw win, rob
        x, y = rob.x, rob.y
        win.angle  x, y,rob.angle, 50, :green
        win.circle x, y, 5, rob.params[:color].to_sym, :filled
      end
    end
  end
end
