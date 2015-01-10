module C0f
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
