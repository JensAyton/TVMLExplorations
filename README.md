## TVMLExplorations
`step0`

This repository is part of a tutorial on writing a TVML host app. See
http://jens.ayton.se/blag/tvml-exploration for more.

This revision contains the basic shell of a TVML application, based on Apple’s
bare-bones example “Creating a Client-Server App” in the prerelease version of
_App Programming Guide for tvOS_.

Note that this revision uses `NSAllowsArbitraryLoads` to allow insecure HTTP
loads as a bootstrapping measure. Don’t do that in a real app.
