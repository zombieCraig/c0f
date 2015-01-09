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
    def match_json(json)
      if json.is_a? Hash then
        fp = json
      else
        fp = JSON.parse(json)
      end
      @db.results_as_hash = true
      if fp["Padding"] then
        sql = "SELECT * FROM fingerprints WHERE dynamic = ? and padding = ? and main_id = ?"
        stm = @db.prepare sql
        stm.bind_params fp["Dynamic"], fp["Padding"], fp["MainID"]
      else
        sql = "SELECT * FROM fingerprints WHERE dynamic = ? and padding is null and main_id = ?"
        stm = @db.prepare sql
        stm.bind_params fp["Dynamic"], fp["MainID"]
      end
      stm.execute
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
