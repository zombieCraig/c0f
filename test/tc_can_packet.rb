require "c0f/can_packet"
require 'test/unit'

class TestCanPacket < Test::Unit::TestCase
  # Output from logs
  def test_parse_log
    pkt = C0f::CANPacket.new
    assert_equal true, pkt.parse("(1398128223.815980) can0 13A#0000000000000028")
    assert_equal 1398128223.815980, pkt.sent
    assert_equal "13A", pkt.id
    assert_equal 8, pkt.dlc
    assert_equal "28".hex, pkt.data[7]
  end

  # Direct output from candump
  def test_parse_candump
    pkt = C0f::CANPacket.new
    assert_equal true, pkt.parse("(1421010803.828887)  can0  128   [3]  A0 00 03")
    assert_equal 1421010803.828887, pkt.sent
    assert_equal "128", pkt.id
    assert_equal 3, pkt.dlc
    assert_equal "03".hex, pkt.data[2]
  end

  # test the 3 known interfaces can0, vcan0, slcan0
  def test_interfaces
    pkt = C0f::CANPacket.new
    assert_equal true, pkt.parse("(1398128223.815980) can0 13A#0000000000000028")
    assert_equal true, pkt.parse("(1398128223.815980) vcan0 13A#0000000000000028")
    assert_equal true, pkt.parse("(1398128223.815980) slcan0 13A#0000000000000028")
  end
end
