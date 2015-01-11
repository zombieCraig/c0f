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
      |--[no-]progress|
      |--[no-]print-fp|
      |--print-stats|
      |--add-fp|
      |--fpdb|
      |--quiet|
      |--sample-size|
      |--save-fp|
    And the banner should document that this app's arguments are:
      | candevice |

  Scenario: Parse a valid CANDump Log with enough sample packets
    Given a valid candump logfile at "/tmp/sample-can.log"
    When I successfully run `c0f --logfile /tmp/sample-can.log --quiet`
    Then the stdout should contain valid JSON
    And the Make is "Unknown" and the Model is "Unknown" and the Year is "Unknown" and the Trim is "Unknown"
    And the common IDs should be "166 158 161 191 18E 133 136 13A 13F 164 17C 183 143 095"
    And the main ID should be "143"
    And the main interval should be "0.009998683195847732"

  Scenario: Take a valid signature and initialze a fingerprint database with it
    Given a completed fingerprint at "/tmp/sample-fp.json" and a fingerprint db at "/tmp/can.db"
    When I successfully run `c0f --add-fp /tmp/sample-fp.json --fpdb /tmp/can.db`
    Then the output should contain "Created Tables"
    And the output should contain "Successfully inserted fingprint"

  Scenario: Match a canbus fingerprint to that in the fingerprint DB
    Given a valid fingerprint db at "/tmp/sample-fp.db" valid logfile "/tmp/sample-can.log"
    When I successfully run `c0f --fpdb /tmp/sample-fp.db --logfile /tmp/sample-can.log --quiet`
    Then the stdout should contain valid JSON
    And the Make is "Honda" and the Model is "Civic" and the Year is "2009" and the Trim is "Hybrid"

