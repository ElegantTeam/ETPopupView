ETPopupView
=============
[![CocoaPods](https://img.shields.io/cocoapods/v/ETPopupView.svg)]()
[![CocoaPods](https://img.shields.io/cocoapods/p/ETPopupView.svg)]()
[![CocoaPods](https://img.shields.io/cocoapods/l/ETPopupView.svg)]()

Swift version of MMPopupView. 


Installation
============

The preferred way of installation is via [CocoaPods](http://cocoapods.org). Just add

```ruby
pod 'ETPopupView'
```

and run `pod install`. It will install the most recent version of ETPopupView.

Usage
===============
If you want to create your own Pop-Up view,simply you only need to subclass from **ETPopupView**.
```swift

class CustomView: ETPopupView {

    let SCREEN_WIDTH = UIScreen.main.bounds.width

    override func awakeFromNib() {
        super.awakeFromNib()
        
        animationDuration = 0.3
        type = .alert
        
        ETPopupWindow.sharedWindow().touchWildToHide = true
        
        self.snp.makeConstraints { (make) in
            make.width.equalTo(SCREEN_WIDTH*0.8)
            make.height.equalTo(214)
        }
    }
}

```

after you customize it, you can simply use it.

```swift

  let customView = Bundle.main.loadNibNamed("CustomView", owner: nil, options: nil)?.first as! CustomView
  customView.show()

```

ETPopupView
===============
ETPopupView is a basic Pop-Up view designed to be subclassed.
It provide 3 kind of animations(alert, sheet), or you can provide your own animation by override the **showAnimation** and **hideAnimation**.

```objc
enum ETPopupType {
    case alert
    case sheet
    case custom
}

typealias ETPopupBlock = (ETPopupView) -> Void
typealias ETPopupCompletionBlock = (ETPopupView, Bool) -> Void

class ETPopupView: UIView {
    
    open var type: ETPopupType = .alert
    
    open var animationDuration: TimeInterval = 0.3
    
    open var visible: Bool
    
    open var attachedView: UIView
    
    open var showCompletionBlock: ETPopupCompletionBlock?
    open var hideCompletionBlock: ETPopupCompletionBlock?
    
    open var showAnimation: ETPopupBlock?
    open var hideAnimation: ETPopupBlock?
}
```

## Contributing

1. Create an issue to discuss about your idea
2. Fork it (https://github.com/VolleyZ/ETPopupView/fork)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
