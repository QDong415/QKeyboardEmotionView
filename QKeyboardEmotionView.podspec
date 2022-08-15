#
# Be sure to run `pod lib lint QKeyboardEmotionView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'QKeyboardEmotionView'
  s.version          = '2.2'
  s.summary          = 'Emotion-Keyboard-Audio-Chat InputBarView'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
An InputBarView At bottom(or below) of ViewController. Contains EmotionBoardView,ExtendBoardView,AudioRecordView.
you can switch between BoardViews and keyboad with animation. It also allows you to customize boardview and inputbarview.It is vert useful for CharViewController and CommentViewController   .
                       DESC

  s.homepage         = 'https://github.com/QDong415/QKeyboardEmotionView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'd19890415' => '285275534@qq.com' }
  s.source           = { :git => 'https://github.com/QDong415/QKeyboardEmotionView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'QKeyboardEmotionView/Classes/**/*'
  
  s.resource = ['QKeyboardEmotionView/Assets/*.*']
#   s.resource_bundles = {
#     'QKeyboardEmotionView' => ['QKeyboardEmotionView/Assets/*.*']
#   }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
