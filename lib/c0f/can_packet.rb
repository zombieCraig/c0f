module C0f
  class CANPacket
    attr_accessor :id, :dlc, :data, :sent, :count, :interval, :sent_history, :deltas, :byte_history
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
      @byte_history = Hash.new # Hash of Hashes per byte location and data type
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

    # Calculates the average delta
    # @return [Float] Average delta between sent intevals
    def avg_delta
      return 0.0 if @deltas.size == 0
      @deltas.inject{ |sum, el| sum + el }.to_f / @deltas.size
    end

    # records each byte and count of changes
    # @param pkt [CANPacket] new packet of same ID
    def record_byte_history(pkt)
      return if not @id == pkt.id
      (0..pkt.data.size-1).each do |i|
        if not @byte_history.has_key? i then
          @byte_history[i] = Hash.new
          @byte_history[i][pkt.data[i]] = 1
        else
          if @byte_history[i].has_key? pkt.data[i] then
            @byte_history[i][pkt.data[i]] += 1
          else
            @byte_history[i][pkt.data[i]] = 1
          end
        end
      end
    end

    def to_s
      s = "#{@id}#"
      @data.each do |x|
        b = x.to_s(16).upcase
        b = "0" + b if b.size == 1
        s += b
      end
      s
    end
  end
end
