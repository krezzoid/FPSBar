# FPSBar

### Usage
```objc
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