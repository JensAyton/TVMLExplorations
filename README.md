## TVMLExplorations
`step1`

This repository is part of a tutorial on writing a TVML host app. See
http://jens.ayton.se/blag/tvml-exploration for more.

This revision demonstrates how to expose a simple, synchronous method to TVJS.

Note that this revision uses `NSAllowsArbitraryLoads` to allow insecure HTTP
loads as a bootstrapping measure. Don’t do that in a real app.
