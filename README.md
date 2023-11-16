# it-smallheists
it-smallheists started as a in inspired project of [qb-miniheists](https://github.com/oosayeroo/qb-miniheists) and is now a Script for the [QBCore Framework ](https://github.com/qbcore-framework/qb-core) script with a lot of fixes, improvements and new Features. 
 
This script is still in development and will be updated frequently. If you have any suggestions or find any bugs, please let us know an open an issue on our [GitHub](https://github.com/inseltreff-net/it-smallheists/issues) page.

A lot of thanks to [LENT-Graverobbery](https://github.com/mkafrin/PolyZone) and [qb-miniheists](https://github.com/oosayeroo/qb-miniheists) we used a lot of code and ideas from them. Check them out if you haven't already.

### We highly recommend you to use the newest version for the best experience!

## Features
- [x] Easy to use
- [x] Configurable
- [x] Optimized
- [x] Translation support
- [x] Multiple heists
- [x] Discord Logs

## Dependencies
You need the following scripts to run this script:
- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-target](https://github.com/qbcore-framework/qb-target)
- [ps-ui](https://github.com/Project-Sloth/ps-ui)
- [PolyZone](https://github.com/mkafrin/PolyZone)

## Installation
1. Download the script and put it in your resources folder.
2. Add the items to your `qb-core/shared/items.lua` file.
3. Make sure you have all the dependencies installed. (See Dependencies)
4. Make sure that all the dependencies are started before you start this script.
5. Configure the script to your liking.
6. Restart your server and you are good to go!

## Items
Add the following items to your `qb-core/shared/items.lua` file.
You can also change the items in the config files to your liking.
```lua
--it-smallheists
    ["lab-usb"]                      = {["name"] = "lab-usb", 				        ["label"] = "USB Research", 			["weight"] = 500, 		["type"] = "item", 		["image"] = "lab-usb.png", 		        ["unique"] = false, 	["useable"] = false, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A USB filled with loads of complicated numbers and letters... Big brain stuff!"},
	['lab-samples'] 		         = {['name'] = 'lab-samples', 			  	   	['label'] = 'Research Samples', 	    ['weight'] = 500, 		['type'] = 'item', 		['image'] = 'lab-samples.png', 		   	['unique'] = false, 	['useable'] = false, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'some creepy samples!'},
	['lab-files'] 				     = {['name'] = 'lab-files', 			  	   	['label'] = 'Research Files', 			['weight'] = 500, 		['type'] = 'item', 		['image'] = 'lab-files.png', 		   	['unique'] = false, 	['useable'] = false, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'lots of big words in these!'},
	['weld'] 				     = {['name'] = 'weld', 			  	   	['label'] = 'Weld', 			['weight'] = 500, 		['type'] = 'item', 		['image'] = 'weld.png', 		   	['unique'] = false, 	['useable'] = false, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'Just a weld'},
	['shovel'] 				 		 = {['name'] = 'shovel', 			    		['label'] = 'Shovel', 					['weight'] = 15000, 	['type'] = 'item', 		['image'] = 'shovel.png', 				['unique'] = false, 	['useable'] = false, 	['shouldClose'] = false,   ['combinable'] = nil,   ['description'] = 'Get Digging!'},
```

## Known Bugs
Currently no known bugs. Feel free to report any bugs you find.

## Future Updates
The plan is to add more heists and features to the script. If you have any suggestions, please let us know.