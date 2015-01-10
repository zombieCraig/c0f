module C0f
  class CANPacketStat
    attr_reader :pkts, :pkt_count, :dynamic
    def initialize
      @pkts = Hash.new
      @pkt_count = 0  # Sample size
      @dynamic = false
    end

    # Adds a CANPacket to the stats
    # @param pkt [CANPacket] Packet to add
    def add(pkt)
      if @pkts.has_key? pkt.id then
        @pkts[pkt.id].update pkt
      else
        @pkts[pkt.id] = pkt
      end
      @pkt_count += 1
      @dynamic = true if pkt.dlc < 8
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
