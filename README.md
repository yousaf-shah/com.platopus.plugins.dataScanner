# DataScanner Plugin

This Solar2D plugin is uses the iOS [DataScannerViewController](https://developer.apple.com/documentation/visionkit/datascannerviewcontroller) pop up to scan and **tap on** text and barcodes to get information you can use in your app.

This plugin also shows how to communicate via Lua<->Objc<->Swift

Note this plugin should be used with devices with iOS/iPadOS 16+ and you need `NSCameraUsageDescription` in plist. 

See `demo` project included in repo.

Developed with Scott Harrison @scottrules44 - big thanks for the Lua - ObjC - Swift Bridge work!!


## APIs

```
local dataScanner = require "plugin.dataScanner"


dataScanner.show{
listener=function(event)
    print(json.encode(event))
end,
highFrameRateTrackingEnabled = true, -- default false
highlightingEnabled = true, -- default false
recognizesMultipleItems = true, -- default false
barCodeSupport = true, -- default false
textSupport = true, -- default false
} --Show scanner view


dataScanner.startScaning()--start the scanner

dataScanner.stopScaning()--stop the scanner
dataScanner.hide()--hides the scanner (and stops the scanner)

```

## Events

The following events are returned with  `dataScanner.show{listener}` 

`event.status` will return the following options
- showDataScanner
- closeDataScanner
- textScan
- barcodeScan

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
			NSCameraUsageDescription="Need for Camera Scanning",
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
