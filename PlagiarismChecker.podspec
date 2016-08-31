#
# Be sure to run `pod lib lint PlagiarismChecker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PlagiarismChecker'
  s.version          = '0.9.0'
  s.summary          = 'Copyleaks detects plagiarism and checks content distribution.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
 Copyleaks detects plagiarism and checks content distribution. Use Copyleaks to find out if textual content is original and if it has been used online. With Copyleaks cloud you can scan files (pdf, doc, docx, ocr...), URLs and free text for plagiarism.
                       DESC
  s.homepage         = 'https://api.copyleaks.com'
  # s.homepage         = 'https://github.com/<GITHUB_USERNAME>/PlagiarismChecker'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Copyleaks' => 'Support@copyleaks.com' }
  # s.source           = { :git => 'https://github.com/Copyleaks/Swift-Plagiarism-Checker.git', :tag => s.version.to_s }
  s.source           = { :git => 'https://github.com/Copyleaks/Swift-Plagiarism-Checker.git'}
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'PlagiarismChecker/Classes/**/*'
  
  # s.resource_bundles = {
  #   'PlagiarismChecker' => ['PlagiarismChecker/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
