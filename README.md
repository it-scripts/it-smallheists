# it-smallheists
 
it-smallheists is inspired by [qb-miniheists](https://github.com/oosayeroo/qb-miniheists/tree/main) and contains a few small heists for [QBCore](https://github.com/qbcore-framework/qb-core). This version of "qb-miniheists" has a lot of fixes and improvements.

This script is still in development and will be updated frequently. If you have any suggestions or find any bugs, please let us know an open an issue on our [GitHub](https://github.com/inseltreff-net/it-smallheists/issues) page.

### We highly recommend you to use the newest version for the best experience!

## Features
- [x] Small heists
- [x] Configurable
- [x] Easy to use
- [x] Optimized
- [x] Translation support


## Dependencies
- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-target](https://github.com/qbcore-framework/qb-target)
- [ps-ui](https://github.com/Project-Sloth/ps-ui)

## Installation
1. Download the script and put it in your resources folder.
2. Add the items to your `qb-core/shared/items.lua` file.
3. Add the following code to your server.cfg/resouces.cfg
```cfg
ensure ps-ui
ensure it-smallheists
```
4. Configure the script to your liking.
5. Restart your server and you are good to go!

## Items
These are the items you currently can´t change in the `config.lua` file. (This will come with future updates)
```lua
--it-smallheists
    ["lab-usb"]                      = {["name"] = "lab-usb", 				        ["label"] = "USB Research", 			["weight"] = 500, 		["type"] = "item", 		["image"] = "lab-usb.png", 		        ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A USB filled with loads of complicated numbers and letters... Big brain stuff!"},
	['lab-samples'] 		         = {['name'] = 'lab-samples', 			  	   	['label'] = 'Research Samples', 	    ['weight'] = 500, 		['type'] = 'item', 		['image'] = 'lab-samples.png', 		   	['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'some creepy samples!'},
	['lab-files'] 				     = {['name'] = 'lab-files', 			  	   	['label'] = 'Research Files', 			['weight'] = 500, 		['type'] = 'item', 		['image'] = 'lab-files.png', 		   	['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'lots of big words in these!'},
```

## Known Bugs
Currently no known bugs. Feel free to report any bugs you find.

## Future Updates
- [ ] Add more heists
- [ ] Clean up the code and optimize it
- [ ] Add more configuration options