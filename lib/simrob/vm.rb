require_relative "vm_opcodes"

module Simrob

  class Vm
    include Opcodes
    attr_accessor :name
    attr_accessor :running
    attr_accessor :pc,:ir
    attr_accessor :ram_i,:ram_d,:reg
    attr_accessor :opcode,:src1,:src2,:dest,:imm
    attr_accessor :robot

    def initialize robot,ram_i_file,ram_d_file
      @robot = robot
      @ram_i = IO.readlines(ram_i_file).map{|s| s.to_i(16)}
      @ram_d = IO.readlines(ram_d_file).map{|s| s.to_i(16)}
      @reg   = Array.new(16){0}
    end

    def print_state
      puts "state #{@robot.name} cycle #{@cycle} | running=#{@running}".center(80,'=')
      max_size=[@ram_i.size,@ram_d.size].max
      puts "     code    |      data"
      for addr in 0..max_size-1
        puts "#{format addr} #{format(@ram_i[addr] || 0)}    | #{format addr} #{format(@ram_d[addr] || 0)}"
      end
      puts "regs:"+(1..15).map{|i| i.to_s.rjust(4)}.join(' ')
      puts "     "+(1..15).map{|i|  format(reg[i])}.join(' ')
    end

    def format val
      case val
      when Float
        val.round(1).to_s.rjust(4)
      when Integer
        val.to_s(16).rjust(4)
      end
    end

    def boot
      @pc=0
      @cycle=0
      @running=true
      print_state
    end

    def run
      step while running
    end

    def step
      @cycle+=1
      fetch
      decode
      execute
    end

    def fetch
      @ir=ram_i[pc] || 0
    end

    def decode
      @opcode =(ir & 0xf000) >> 12
      @src1   =(ir & 0x0f00) >>  8
      @src2   =(ir & 0x00f0) >>  4
      @imm    =(ir & 0x00f0) >>  4
      @dest   =(ir & 0x000f)
    end

    def execute
      @pc+=1
      case opcode
      when ADD
        reg[dest]=reg[src1] + reg[src2]
      when SUB
        reg[dest]=reg[src1] - reg[src2]
      when MUL
        reg[dest]=reg[src1] * reg[src2]
      when DIV
        reg[dest]=reg[src1] / reg[src2]
      when OR
        reg[dest]=reg[src1] | reg[src2]
      when AND
        reg[dest]=reg[src1] & reg[src2]
      when NOT
        reg[dest]= ~reg[src1]
      when LOAD
        reg[dest]=ram_d[ reg[src1] + imm ]
      when STORE
        ram_d[ reg[dest] + imm ] = reg[src1]
      when JMP
        pc = reg[dest] + imm
      when CJMP
        pc = reg[dest] + imm if reg[src1]/=0
      # -------------------------------------------------------
      # DMA-like read/written at mem data dedicated locations
      # ---------------------------------------------------------
      when GET_SENSOR
        reg[dest]=ram_d[@dma_addr+reg[src1]]
      when SET_ACTUATOR
        ram_d[@dma_addr+dest]=reg[src1]
      when STOP
        puts "stopping #{name}"
        @running = false
      end
      reg[0]=0 # classical RISC trick
      # TBC with interval-specific instructions !
    end
  end
end
