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

  # Checks recording on counts and deltas
  def test_updates
    pkt = C0f::CANPacket.new
    pkt.parse("(1398128223.815980) can0 13A#0000000000000028")
    pkt2 = C0f::CANPacket.new
    pkt2.parse("(1398128223.816980) can0 13A#000000000000008A")
    pkt.update pkt2
    pkt2.parse("(1398128223.817980) can0 13A#00000000000000FF")
    pkt.update pkt2
    assert_equal 3, pkt.count, "Packet count"
    assert_equal 2, pkt.deltas.size, "Delta size"
    assert_equal 0.001000046730041504, pkt.avg_delta, "Avg Delta"
  end

  # Check if byte history count is accurate based on differences
  def test_byte_history
    pkt = C0f::CANPacket.new
    pkt.parse("(1398128223.815980) can0 13A#A10003")
    pkt2 = C0f::CANPacket.new
    pkt2.parse("(1398128223.816980) can0 13A#A10003")
    pkt.record_byte_history pkt2
    pkt2.parse("(1398128223.817980) can0 13A#A20004")
    pkt.record_byte_history pkt2
    pkt2.parse("(1398128223.817980) can0 13A#A30003")
    pkt.record_byte_history pkt2
    pkt2.parse("(1398128223.817980) can0 13A#A20004")
    pkt.record_byte_history pkt2
    assert_equal 3, pkt.byte_history.size, "Byte history size"
    assert_equal 3, pkt.byte_history[0].size, "First byte size #{pkt.byte_history[0].inspect}"
    assert_equal 1, pkt.byte_history[1].size, "Second byte size"
    assert_equal 2, pkt.byte_history[2].size, "Third byte size"
  end
end
