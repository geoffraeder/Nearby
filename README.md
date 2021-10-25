#  Nearby App
##### Sample iOS application the demonstrates fetching restaurants from the Google Place API

* Requires Xcode 13/iOS 15
* Suggest running on device
* General arctitecture revolves around a container controller that manages child controllers to display data in either map or list format.

* The presentation layer integrates with a service and network layer via depenency injection.

* Includes lightweight persistence for saving "favorite" places.

* Includes a basic unit test to verify Place data decoding

* Caveats
	* Doesn't support Google API paging
	* Bookmark button doesn't seem to work on the simulator