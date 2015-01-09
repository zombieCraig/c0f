== CAN of Fingers

CAN of Fingers (c0f) is lovingly based off of the passive network OS detection tool p0f.
c0f is designed to analyze CAN bus traffic and fingerprint the Make and Model.  This
tool is still very experimental and alpha and is currently being used as a proof of concept.

== Author

Craig Smith (craig@theialabs.com) for Open Garages

== Requirements / Install

Currently this toolset is a collection of Ruby tools but may unltimately be ported to C.
We overkilled the ruby modules for this tool but the C one will be streamlined.  promise.

Tested with ruby 2.1.5

Get dependencies with:

$ bundle 

Run the app

$ bundle exec bin/c0f

== Tests

These are currently broken and honestly are nothing but the bootstrap tests anyhow

