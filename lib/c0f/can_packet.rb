module C0f
  class CANPacket
    attr_accessor :id, :dlc, :data, :sent, :count, :interval, :sent_history, :deltas
    def initialize
      @id = 0
      @dlc = 0
      @data = Array.new
      @sent = nil
      # Statistical items
      @count = 0
      @interval = 0
      @sent_history = []
      @deltas = []
    end

    # Parses CANDump line into CANPacket
    # @param line [String] CANDump line
    # @return [Boolean] true if successful
    def parse(line)
             # (1398128223.815980) can0 13A#0000000000000028
      if line=~/\((\d+\.\d+)\) [s]?[l|v]?can\d+ (\w+)#(\w+)/ then
        @sent = $1.to_f
        @id = $2
        @data = $3.scan(/../).map(&:hex)
        @dlc = @data.size
        @count = 1
	return true
              # (1421010803.828887)  slcan0  128   [3]  A0 00 03
      elsif line=~/\((\d+\.\d+)\)\s+[s]?[l|v]?can\d+\s+(\w+)\s+\[(\d+)\]  (.+)/ then
        @sent = $1.to_f
        @id = $2
        @dlc = $3.to_i
        @data = $4.gsub(' ','')
        @data = @data.scan(/../).map(&:hex)
        @count = 1
        return true
      end
      false
    end

    # Updates stats when the ID matches for a packet
    # @param pkt [CANPacket]
    def update(pkt)
      return if not pkt.id == @id
      @count += 1
      @sent_history.push @sent
      @deltas.push  (pkt.sent - @sent)
      @sent = pkt.sent
    end

    # @return [Float] Average delta between sent intevals
    def avg_delta
      return 0.0 if @deltas.size == 0
      @deltas.inject{ |sum, el| sum + el }.to_f / @deltas.size
    end
  end
end
