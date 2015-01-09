== CAN of Fingers

CAN of Fingers (c0f) is lovingly based off of the passive network OS detection tool p0f.
c0f is designed to analyze CAN bus traffic and fingerprint the Make and Model.  This
tool is still very experimental and alpha and is currently being used as a proof of concept.

== Author

Craig Smith (craig@theialabs.com) for Open Garages

== Requirements / Install

Currently this toolset is a collection of Ruby tools but may unltimately be ported to C.
We overkilled the ruby modules for this tool but the C one will be streamlined.  promise.

NOTE: I'm not a ruby proffesional coder (er what do they call it, craftsman?) which is why
I appologized for using more gems than necessary (instead of being proud of it).
I'm also horrible at using cucumber and these other methodologies which I find PAINFUL.
However, I did at least make some attempt at this.  May all you ruby craftsmen feel my pain
by reading my horrid code :)

Tested with ruby 2.1.5

Get dependencies with:

$ bundle 

Run the app

$ bundle exec bin/c0f --help

== Using c0f

First you will want to use candump from can-utils (on linux) to record some CAN traffic from
a vehicle that is turned completed on (not just in Auxilary mode).  You will want at least 2000
packets...which should only take a few seconds but more won't hurt anything.  Have candump
log this to a file.  For instance

$ candump -l /tmp/mycan.log -n 5000

now you can run c0f on it to get a fingerprint

$ bundle exec bin/c0f --logfile /tmp/mycan.log

This should output some JSON

```json
{"Make": "Unknown", "Model": "Unknown", "Year": "Unknown", "Trim": "Unknown", "Dynamic": "true", "Common": [ { "ID": "166" },{ "ID": "158" },{ "ID": "161" },{ "ID": "191" },{ "ID": "18E" },{ "ID": "133" },{ "ID": "136" },{ "ID": "13A" },{ "ID": "13F" },{ "ID": "164" },{ "ID": "17C" },{ "ID": "183" },{ "ID": "143" },{ "ID": "095" } ], "MainID": "143", "MainInterval": "0.009998683195847732"}
```
The fingerprint is calculated by a few things:

* Signal ID
* Signal Intervals
* Dynamic Size DLC
* Padding (if not dynamic)

Parts of the fingerprint that need explaining are:

* Common IDs are Signal IDs that repeat a lot on the bus.
* MainID is the most common signal with the highest interval rate
* MainInterval is that rate

Assuming you know what vehilce you are attached to you can create a file with this JSON
data in it and fill in the Make, Model, etc.  Then you can add it to a DB like so:

```
$  bundle exec bin/c0f --add-fp /tmp/fp --fpdb /tmp/candb
Created Tables
Loaded 0 fingerprints from DB
Successfully inserted fingprint (1) 
```

Now if you check the logfile against the database it should correctly identify the vehicle

$ bundle exec bin/c0f --logfile /tmp/mycan.log --fpdb /tmp/candb

```json
{"Make": "Honda", "Model": "Civic", "Year": "2009", "Trim": "Hybrid", "Dynamic": "true", "Common": [ { "ID": "166" },{ "ID": "158" },{ "ID": "161" },{ "ID": "191" },{ "ID": "18E" },{ "ID": "133" },{ "ID": "136" },{ "ID": "13A" },{ "ID": "13F" },{ "ID": "164" },{ "ID": "17C" },{ "ID": "183" },{ "ID": "143" },{ "ID": "095" } ], "MainID": "143", "MainInterval": "0.009998683195847732"}
```

== Tests

These are currently broken and honestly are nothing but the bootstrap tests anyhow

== Fingerprint DBs

Currently this repo does not include a fingerprint database .... yet
