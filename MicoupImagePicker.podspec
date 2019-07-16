#
# Be sure to run `pod lib lint react-native-micoup-image-picker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

require 'json'
package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name             = 'MicoupImagePicker'
  s.version          = package["version"]
  s.summary          = 'A short description of react-native-micoup-image-picker.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = package["description"]

  s.homepage         = 'https://github.com/kimkr/react-native-micoup-image-picker'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kimkr' => 'dev.kimkr@gmail.com' }
  s.source           = { :git => 'https://github.com/kimkr/react-native-micoup-image-picker.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'ios/MicoupImagePicker/Classes/**/*.{h,m}'
  
  s.resource_bundles = {
    'Resources' => [
      'ios/MicoupImagePicker/Assets/*.{storyboard}',
      'ios/MicoupImagePicker/Assets/*.{xcassets}'
    ]
  }
  
  s.public_header_files = [
    'ios/MicoupImagePicker/Classes/MCPMicoupImagePicker.h',
    'ios/MicoupImagePicker/Classes/ViewController/*.{h}',
    'ios/MicoupImagePicker/Classes/Model/*.{h}'
  ]

  s.frameworks = 'UIKit'
  
  s.dependency 'React'
  s.dependency 'NYXImagesKit'
  s.dependency 'SDWebImage'
  s.dependency 'AFNetworking'
  s.dependency 'POSInputStreamLibrary'
  s.dependency 'MRProgress'
  s.dependency 'UIAlertController+Blocks'
  s.dependency 'UIColor+Hex'
  s.dependency 'Toast'
  s.dependency 'NSString-UrlEncode'
  s.dependency 'UIButton+BackgroundColor'
  s.dependency 'UIAlertController+Blocks'
end
