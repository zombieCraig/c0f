# Put your step definitions here
require "fileutils"
require 'json'

Given(/^a valid candump logfile at "(.*?)"$/) do |logfile|
  FileUtils.copy "test/sample-can.log", logfile
end

Then(/^the stdout should contain valid JSON$/) do
    expect { JSON.parse(all_output) }.not_to raise_error
end

Then(/^the common IDs should be "(.*?)"$/) do |idstr|
  ids = idstr.split
  fp = JSON.parse(all_output)
  missing = false
  ids.each do |id|
    found = false
    fp["Common"].each do |cid|
      found = true if cid["ID"] == id
    end
    missing = true if not found
  end
  expect(missing).to be_falsey
end

Then(/^the main ID should be "(.*?)"$/) do |id|
  fp = JSON.parse(all_output)
  expect(fp["MainID"] == id).to be_truthy
end

Then(/^the main interval should be "(.*?)"$/) do |i|
  fp = JSON.parse(all_output)
  expect(fp["MainInterval"] == i).to be_truthy
end

Given(/^a completed fingerprint at "(.*?)" and a fingerprint db at "(.*?)"$/) do |fp_dest, candb_dest|
  File.unlink candb_dest if File.exists? candb_dest
  FileUtils.cp "test/sample-fp.json", fp_dest
end

Given(/^a valid fingerprint db at "(.*?)" valid logfile "(.*?)"$/) do |db_dest, log_dest|
  FileUtils.cp "test/sample.db", db_dest
  FileUtils.cp "test/sample-can.log", log_dest
end

Then(/^the Make is "(.*?)" and the Model is "(.*?)" and the Year is "(.*?)" and the Trim is "(.*?)"$/) do |make, model, year, trim|
  fp = JSON.parse(all_output)
  expect((fp["Make"] == make and fp["Model"] == model and fp["Year"] == year and fp["Trim"] == trim)).to be_truthy
end

Given(/^the pattern "(.*?)" at the logfile "(.*?)"$/) do |pattern, log_dest|
  FileUtils.cp "test/sample-can.log", log_dest
end

Then(/^should return one pattern match$/) do
  j = JSON.parse(all_output)
  expect(j["Matches"].size).to eq(1)
end

Then(/^the identified signal ID should be "(.*?)" at position "(.*?)" with possibilities of "(.*?)"$/) do |id, pos, values|
  j = JSON.parse(all_output)
  values = values.split
  first = j["Matches"][0]
  expect((first["ID"] == id and first["Position"] == pos and first["Values"][0] = values[0] and first["Values"][1] == values[1])).to be_truthy
end
