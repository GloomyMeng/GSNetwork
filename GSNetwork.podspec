#
# Be sure to run `pod lib lint GSNetwork.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GSNetwork'
  s.version          = '0.0.2'
  s.summary          = 'Network components of the GS series components'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Network components of the GS series components. Depends on Alamofire.
                       DESC

  s.homepage         = 'https://github.com/GloomyMeng/GSNetwork'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'gloomy.meng.049@gmail.com' => 'gloomy.meng.049@gmail.com' }
  s.source           = { :git => 'https://github.com/GloomyMeng/GSNetwork.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.swift_version = '5.0'
  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.tvos.deployment_target = '10.0'

  s.source_files = 'GSNetwork/Classes/**/*'
  s.dependency 'GSBasis'
  s.dependency 'Alamofire', '~> 5.0.0-beta.5'
end
