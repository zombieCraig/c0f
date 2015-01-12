module C0f
  class CANPacketStat
    attr_reader :pkts, :pkt_count, :dynamic
    attr_accessor :pattern
    def initialize
      @pkts = Hash.new
      @pkt_count = 0  # Sample size
      @dynamic = false
      @pattern = nil
      @history = Hash.new
    end

    # Adds a CANPacket to the stats
    # @param pkt [CANPacket] Packet to add
    def add(pkt)
      if @pkts.has_key? pkt.id then
        filter_pattern(@pkts[pkt.id], pkt)
        @pkts[pkt.id].update pkt
        @history[pkt.id] << pkt if @pattern
      else
        @pkts[pkt.id] = pkt
	@history[pkt.id] = [ pkt ] if @pattern
      end
      @pkt_count += 1
      @dynamic = true if pkt.dlc < 8
    end

    # When a pattern is given check the pattern history
    # @param pkt [CANPacket] Packet to check byte change history
    def filter_pattern(mainpkt, newpkt)
      return if not @pattern
      mainpkt.record_byte_history newpkt
    end

    # If a pattern is defined search through the byte history for a mathc
    # returns [Hash] of matching packets, positions and values
    def find_pattern_matches
      matches = Array.new
      # Phase 1 - Identify only 2 possible changes
      @pkts.each_value do |pkt|
        # for now just check for binary toggles
        pkt.byte_history.each do |pos, changes|
          if changes.size == 2
            match = Hash.new
            match["pkt"] = pkt
            match["pos"] = pos
            match["values"] = changes.keys
            matches << match
          end
        end
      end
      # Phase 2 - Changes anaylzed to see if squence matches pattern
      tmpmatches = Array.new
      matches.each do |match|
        sigpattern = ""
        @history[match["pkt"].id].each do |pkt|
          if pkt.data[match["pos"]] == match["values"][0] then
            sigpattern += "b"
          else
            sigpattern += "B"
          end
        end
        tmpmatches << match if sigpattern.index @pattern
        sigpattern.swapcase!
        tmpmatches << match if sigpattern.index @pattern
      end
      tmpmatches
    end

    def to_s
      s = "Packet Count (Sample Size): #{@pkt_count}\n"
      s += "Dynamic bus: #{@dynamic}\n"
      s += "[Packet Stats]\n"
      @pkts.each_value do |pkt|
        s += " #{pkt.id} [#{pkt.dlc}] interval #{pkt.avg_delta} count #{pkt.count}\n"
      end
      s
    end
  end # CANPacketStat
end
