# DataScanner Plugin

This Solar2D plugin is uses the iOS [DataScannerViewController](https://developer.apple.com/documentation/visionkit/datascannerviewcontroller) pop up to scan and **tap on** text and barcodes to get information you can use in your app.

This plugin also shows how to communicate via Lua<->Objc<->Swift

Developed with Scott Harrison @scottrules44 - big high five 🙌 for the Lua - ObjC - Swift Bridge work!!

## Restrictions

This plugin will only work with iOS/iPadOS 16+, a device with at least a Bionic A12 processor, and you need a `NSCameraUsageDescription` in your app's plist. 
The Bionic A12 was first used in iPhone XS and XS Max, iPhone XR, iPad Air (3rd generation), iPad Mini (5th generation), 8th generation iPad.
Devices before these will return a false from `dataScanner.show` and `dataScanner.scanningIsSupported` so you should warn users of this to avoid frustration!

## Example

```
local dataScanner = require "plugin.dataScanner"

local scannerOk = dataScanner.show{

	listener = datascanner.listener ,
	highFrameRateTrackingEnabled = true,
	highlightingEnabled = true,
	recognizesMultipleItems = false,
	barCodeSupport = true,
	textSupport = false,

}

if scannerOk then

	dataScanner.startScanning()

end
```

Functions included:

```
(Boolean) scanningOK = dataScanner.show{ listener, highFrameRateTrackingEnabled, highlightingEnabled, recognizesMultipleItems, barCodeSupport, textSupport }
dataScanner.startScanning()  --start the scanner (if you get a true back from dataScanner.show)
dataScanner.stopScanning()  --stop the scanner
dataScanner.hide(). --hides the scanner (and stops the scanner)
(Boolean) isSupported = dataScanner.scanningIsSupported()  -- is the device capable of using the scanner?  (see restrictions below)
(Boolean) isAvailable = dataScanner.scanningIsAvailable()  -- does the app have permission - i.e. NSCameraUsageDescription & the user approved the camera usage
```

## Events

The following events are returned with  `dataScanner.show{listener}` 

`event.status` will return the following options
- showDataScanner  -- the scanner was shown
- closeDataScanner  -- the scanner was closed
- textScan  -- received a text scan
- barcodeScan  -- received a barcode

`event.data` for event.status "textScan" or "barcodeScan" will return a string of the scanned data

## Build.settings

```
settings =
{

	iphone =
	{
		xcassets = "Images.xcassets",
		plist =
		{
			NSCameraUsageDescription = "This App needs the camera for text / barcode scanning",
			UILaunchStoryboardName = "LaunchScreen",
		},
	},
	plugins =
    {
        ["plugin.dataScanner"] =
        {
            publisherId = "com.platopus",
            supportedPlatforms = {
                iphone = { url="https://github.com/yousaf-shah/com.platopus.plugins.dataScanner/releases/download/1.0.0/dataScanner_iOS.tgz" },
                ["mac-sim"] = { url="https://github.com/yousaf-shah/com.platopus.plugins.dataScanner/releases/download/1.0.0/dataScanner_lua.tgz" },
                ["win32-sim"] = { url="https://github.com/yousaf-shah/com.platopus.plugins.dataScanner/releases/download/1.0.0/dataScanner_lua.tgz" },
            },
        },
    },
}


```
