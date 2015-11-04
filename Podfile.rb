source 'https://github.com/CocoaPods/Specs.git'

# 创建Podfile:
# ln -fs Podfile.rb Podfile

workspace 'PRKKitWorkSpace.xcworkspace'
xcodeproj 'Demo/Demo.xcodeproj'

platform :ios, '8.0'
use_frameworks!

pod 'JGProgressHUD' # HUD

pod 'SnapKit', '~> 0.15.0'
pod 'Alamofire', '~> 3.0.1'
pod 'SDWebImage', '~> 3.7.3'

pod 'ICSPullToRefresh', '~> 0.2'
pod 'CocoaLumberjack/Swift'
pod 'JRSwizzle', '~> 1.0'
pod 'Reachability', '~> 3.2'
pod 'RegexKitLite', '~> 4.0'