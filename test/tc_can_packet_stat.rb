require "c0f/can_packet"
require "c0f/can_packet_stat"
require 'test/unit'

class TestCanPacket < Test::Unit::TestCase
  def test_toggle_patterns
    pkt = C0f::CANPacket.new
    stat = C0f::CANPacketStat.new
    stat.pattern = "BbBbBBBb"
    pkt.parse("(1398128223.815980) can0 13A#A10003")
    stat.add pkt
    pkt = C0f::CANPacket.new
    pkt.parse("(1398128223.816980) can0 13A#A10003")
    stat.add pkt
    pkt = C0f::CANPacket.new
    pkt.parse("(1398128223.817980) can0 13A#A20004")
    stat.add pkt
    pkt = C0f::CANPacket.new
    pkt.parse("(1398128223.817980) can0 13A#A30003")
    stat.add pkt
    pkt = C0f::CANPacket.new
    pkt.parse("(1398128223.817980) can0 13A#A20004")
    stat.add pkt
    pkt = C0f::CANPacket.new
    pkt.parse("(1398128223.817980) can0 101#A20004")
    stat.add pkt
    pkt = C0f::CANPacket.new
    pkt.parse("(1398128223.817980) can0 101#A20004")
    stat.add pkt
    pkt = C0f::CANPacket.new
    pkt.parse("(1398128223.817980) can0 110#AABBCC")
    stat.add pkt
    pkt = C0f::CANPacket.new
    pkt.parse("(1398128223.817980) can0 13A#A20003")
    stat.add pkt
    pkt = C0f::CANPacket.new
    pkt.parse("(1398128223.817980) can0 13A#A20004")
    stat.add pkt
    pkt = C0f::CANPacket.new
    pkt.parse("(1398128223.817980) can0 13A#A20004")
    stat.add pkt
    pkt = C0f::CANPacket.new
    pkt.parse("(1398128223.817980) can0 13A#A20004")
    stat.add pkt
    pkt = C0f::CANPacket.new
    pkt.parse("(1398128223.817980) can0 13A#A20003")
    stat.add pkt
    pkt = C0f::CANPacket.new
    pkt.parse("(1398128223.817980) can0 13A#A20004")
    stat.add pkt
    assert_equal 1, stat.find_pattern_matches.size, "Pattern results"
  end
end
