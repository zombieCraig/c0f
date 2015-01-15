require 'sqlite3'
require 'json'

module C0f

  class CANFingerprintDB
    def initialize(dbfile)
      @db = nil
      if File.exists? dbfile then
        @db = SQLite3::Database.new(dbfile)
      else
        @db = SQLite3::Database.new(dbfile)
        create_tables
      end
    end

    def create_tables
      @db.execute <<SQL
CREATE TABLE fingerprints (
  idx INTEGER PRIMARY KEY,
  make VARCHAR(20),
  model VARCHAR(25),
  year VARCHAR(5),
  trim VARCHAR(20),
  dynamic BOOLEAN,
  padding VARCHAR(4),
  main_id VARCHAR(4),
  main_interval FLOAT
);
SQL
      @db.execute <<SQL
CREATE TABLE common (
  idx INTEGER PRIMARY KEY,
  fingerprint_id INTEGER,
  id VARCHAR(4)
);
SQL
      puts "Created Tables"
    end #create_tables

    # Inserts a JSON fingerprint into the DB
    def insert_json(json)
      if json.is_a? Hash then
        fp = json
      else
        fp = JSON.parse(json)
      end
      sql = "INSERT INTO fingerprints (make, model, year, trim, dynamic, padding, main_id, main_interval) VALUES (?,?,?,?,?,?,?,?)"
      fp["Padding"] = nil if not fp.has_key? "Padding"
      @db.execute(sql, fp.values_at("Make","Model","Year","Trim","Dynamic","Padding","MainID","MainInterval"))
      fingerprint_id = @db.last_insert_row_id
      sql = "INSERT INTO common (fingerprint_id, id) VALUES (?,?)"
      fp["Common"].each do |common|
        @db.execute(sql, fingerprint_id, common["ID"])
      end
      fingerprint_id
    end

    # Try to find a match from a JSON fingerprint
    # @param json [JSON] fingerprint JSON
    # @return [Hash] Updates JSON Hash and adds "Confidence"
    def match_json(json)
      if json.is_a? Hash then
        fp = json
      else
        fp = JSON.parse(json)
      end
      @db.results_as_hash = true
      # New Method
      # Go through all the fingerprints and retrieve the common IDs of each signal
      # Count how many match to how many didn't match
      target_total = fp["Common"].count
      fingerprints = Hash.new
      sql = "SELECT fingerprint_id, id FROM common ORDER BY fingerprint_id"
      r = @db.execute sql
      r.each do |row|
        if not fingerprints.has_key? row["fingerprint_id"] then
          fingerprints[row["fingerprint_id"]] = Hash.new
          fingerprints[row["fingerprint_id"]]["Total"] = 1
          fingerprints[row["fingerprint_id"]]["Matched"] = 0
        else
          fingerprints[row["fingerprint_id"]]["Total"] += 1
        end
        fp["Common"].each do |common|
          if row["id"] == common["ID"] then
            fingerprints[row["fingerprint_id"]]["Matched"] += 1
          end
        end
      end      
      best_id = 0
      best_score = 0
      fingerprints.each do |id, m|
        fp_signals_didnt_match = m["Total"] - m["Matched"]
        target_signals_didnt_match = target_total - m["Matched"]
        deduction = 100 / (m["Total"] + target_total)
        score = 100 - ( (deduction * fp_signals_didnt_match) + (deduction * target_signals_didnt_match) )
        if score > best_score then
          best_score = score
          best_id = id
        end
      end
      fp["Confidence"] = 0
      if best_id > 0 then
        fp["Confidence"] = best_score
        sql = "SELECT make,model,year,trim FROM fingerprints WHERE idx = ?"
        stm = @db.prepare sql
        stm.bind_params best_id
        r = stm.execute
        row = r.next
        fp["Make"] = row["make"]
        fp["Model"] = row["model"]
        fp["Year"] = row["year"]
        fp["Trim"] = row["trim"]
      end
      fp
    end

    # Retrieve all the fingerprints
    def all
      sql = "SELECT * FROM fingerpints"
      @db.execute(sql)
    end

    # Get's the common IDs for a given fingerprint
    def common_id(fingerprint_id)
      sql = "SELECT id FROM common WHERE fingerprint_id = ?"
      stm = @db.prepare sql
      stm.bind_param fingerprint_id
      stm.execute
    end

    # Returns the total amount of fingerprints in the DB
    def count
      sql = "SELECT count(1) FROM fingerprints"
      @db.get_first_value sql
    end

  end
end
