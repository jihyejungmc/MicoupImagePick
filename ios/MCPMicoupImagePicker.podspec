#
# Be sure to run `pod lib lint react-native-micoup-image-picker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MCPMicoupImagePicker'
  s.version          = '0.1.0'
  s.summary          = 'A short description of react-native-micoup-image-picker.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/kimkr/react-native-micoup-image-picker'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kimkr' => 'dev.kimkr@gmail.com' }
  s.source           = { :git => 'https://github.com/kimkr/react-native-micoup-image-picker.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'MCPMicoupImagePicker/Classes/**/*.{h,m}'
  
  s.resource_bundles = {
    'Resources' => [
      'MCPMicoupImagePicker/Assets/*.{png}',
      'MCPMicoupImagePicker/Assets/*.{storyboard}',
      'MCPMicoupImagePicker/Assets/*.{xcassets}'
    ]
  }
  
  s.public_header_files = [
    'MCPMicoupImagePicker/Classes/MCPMicoupImagePicker.h',
    'MCPMicoupImagePicker/Classes/ViewController/*.{h}',
    'MCPMicoupImagePicker/Classes/Model/*.{h}'
  ]

  s.frameworks = 'UIKit'
  
  s.dependency 'React/Core'
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
