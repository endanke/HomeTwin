# HomeTwin

## Overview

This project is a simple, customizable, 3D smart home visualization tool, created using Apple's [HomeKit framework](https://developer.apple.com/documentation/homekit/) and [Mapbox Maps SDK](https://docs.mapbox.com/ios/maps/guides/).

Read more on my blog about the data preparation steps: [https://headprocess.com/other/2025/02/12/hometwin](https://headprocess.com/other/2025/02/12/hometwin)

![IMG_0158](https://github.com/user-attachments/assets/baaa2229-5d83-46bd-b0de-e492560e6f91)

Features:
- Georeferenced indoor map, customizable to your home
- Multi floor support with floor selector
- Control state of lamps and power sockets
- Display temperature sensor data

## Getting started

1. Create `HomeTwin/Info.plist` with the following content, fill in the blanks with the required values:
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>MBXAccessToken</key>
	<string>...</string>
	<key>neLongitude</key>
	<real>...</real>
	<key>neLatitude</key>
	<real>...</real>
	<key>swLongitude</key>
	<real>...</real>
	<key>swLatitude</key>
	<real>...</real>
</dict>
</plist>

```

- To get a Mapbox access token, head over to their documentation:
[https://docs.mapbox.com/ios/maps/guides/install/](https://docs.mapbox.com/ios/maps/guides/install/)

- The coordinates represent the bounds of the map around the indoor location: ne stands for northeast, sw is for southwest.

2. Add the map data source under `HomeTwin/home.geojson`

3. Build and enjoy!
