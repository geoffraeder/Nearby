#  Nearby App
##### Sample iOS application the demonstrates fetching restaurants from the Google Place API

General arctitecture revolves around a container controller that manages child controllers to display data in either map or list format.

The presentation layer integrates with a service and network layer via depenency injection.

* Requires Xcode 13/iOS 15
* Caveats
 - Doesn't support Google API paging
 - Bookmark button doesn't seem to work on the simulator