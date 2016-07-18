# FPSBar
[![codebeat badge](https://codebeat.co/badges/258d3467-b079-4326-842e-b66c435b8257)](https://codebeat.co/projects/github-com-krezzoid-fpsbar)

### Usage
```swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

//
// some of your code here ...
//

// display FPS bar
let bar: FPSbar = FPSbar(frame: UIApplication.sharedApplication().statusBarFrame)
bar.desiredChartUpdateInterval = 1.0 / 10.0
bar.showsAverage = true
bar.initilize()
bar.hidden = false

return true
}
```
