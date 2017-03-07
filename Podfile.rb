source 'https://github.com/CocoaPods/Specs.git'

# 创建Podfile:
# ln -fs Podfile.rb Podfile

workspace 'PRKKitWorkSpace.xcworkspace'
xcodeproj 'Demo/Demo.xcodeproj'

platform :ios, '8.0'
use_frameworks!

target "Demo" do
    pod 'JGProgressHUD', '~> 1.4'
    pod 'SnapKit', '~> 3.2.0'
    pod 'Alamofire', '~> 4.4.0'
    pod 'SDWebImage', '~> 4.0.0'
    pod 'ICSPullToRefresh', '~> 0.6'
    pod 'CocoaLumberjack/Swift'
    pod 'JRSwizzle', '~> 1.0'
    pod 'Reachability', '~> 3.2'
    pod 'RegexKitLite', '~> 4.0'

end

