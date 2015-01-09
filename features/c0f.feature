Feature: Analyze CAN Bus fingerprints
  In order to determine fingerprints for CAN Bus traffic
  I want to have a tool that can analyze, save and report CAN bus fingerprints
  So I can eventually make fingerprints for shellcode

  Scenario: Basic UI
    When I get help for "c0f"
    Then the exit status should be 0
    And the banner should be present
    And the banner should document that this app takes options
    And the following options should be documented:
      |--version|
      |--logfile|
      |--[no-]print-fp|
      |--add-fp|
      |--fpdb|

  Scenario: Parse CANDump Log
    Given a valid candump logfile at "test/sample-can.log"
    When I successfully run "c0f --logfile test/sample-can.log"
    Then A fingerprint should be displayed
