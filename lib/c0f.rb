require "c0f/version"
require "c0f/can_fingerprint_db"

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
    # Expected format: (1398128223.815980) can0 13A#0000000000000028
    # @param line [String] CANDump line
    # @return [Boolean] true if successful
    def parse(line)
      if line=~/\((\d+\.\d+)\) [sl|v]?can\d+ (\w+)#(\w+)/ then
        @sent = $1.to_f
        @id = $2
        @data = $3.scan(/../).map(&:hex)
        @dlc = @data.size
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

  class CANFingerprint
    attr_reader :common_ids, :most_common, :padding
    attr_accessor :make, :model, :year, :trim
    # Requires CANPacketStat
    def initialize(stats, db=nil)
      @stats = stats
      @db = db
      @most_common = nil
      @common_ids = Array.new
      @padding = nil
      self.analyze
      @make = "Unknown"
      @model = "Unknown"
      @year = "Unknown"
      @trim = "Unknown"
    end

    # intended for direct access to the most common IDs interval
    def main_interval
      @most_common.avg_delta
    end

    def main_id
      @most_common.id
    end

    # helper function
    def dynamic
      @stats.dynamic
    end

    def to_s
      s = "Make: #{@make} Model: #{@model} Year: #{@year} Trim: #{@trim}\n"
      s += "Dyanmic: #{@stats.dynamic}\n"
      s += "Padding: 0x#{@padding}\n" if @padding.to_s(16).upcase
      s += "Common IDs: #{@common_ids}\n"
      s += "Most Common: #{@most_common.id} Expected interval: #{@most_common.avg_delta}ms\n"
      s
    end

    def to_json
     s = '{"Make": "' + @make + '", "Model": "' + @model + '", "Year": "' + @year + '", "Trim": "' + @trim + '"'
     s += ', "Dynamic": "' + (@stats.dynamic ? "true" : "false") + '", '
     s += '"Padding": "' + @padding.to_s(16).upcase + '", ' if @padding
     s += '"Common": [ '
     json_ids = Array.new
     @common_ids.each do |id|
       json_ids << '{ "ID": "' + id + '" }'
     end
     s += json_ids.join(',')
     s += ' ], "MainID": "' + @most_common.id + '", "MainInterval": "' + @most_common.avg_delta.to_s + '"'
     s += "}"
     s
    end

    # Analyzes the CANPacketStats
    # @stat must be set
    def analyze
      high_count = 0
      padd_stat = Hash.new
      # First pass
      # * calculate the IDs we saw the most
      @stats.pkts.each_value do | pkt|
        high_count = pkt.count if pkt.count > high_count
        if not @stats.dynamic then
          if padd_stat.has_key? pkt.data[-1] then
            padd_stat[pkt.data[-1]] += 1
          else
            padd_stat[pkt.data[-1]] = 1
          end
        end
      end
      # Second pass
      fastest_interval = 5.0
      @stats.pkts.each_value do |pkt|
        # Common IDs are ones that the highest report - 1% of the total reported
        if pkt.count >= high_count - (@stats.pkt_count * 0.01) then
          @common_ids << pkt.id
          if pkt.avg_delta < fastest_interval then
            fastest_interval = pkt.avg_delta
            @most_common = pkt
          end
        end
      end
      if @stats.dynamic then
        highest_pad = 0
        padd_stat.each do |val, count|
          if count > highest_pad
            hightest_pad = count 
            @padding = val
          end
        end
      end
    end
  end # CANFingerprint
end
