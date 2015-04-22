#
# Be sure to run `pod lib lint Emo.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Emo"
  s.version          = "0.1.0"
  s.summary          = "iOS emoji keyboard library written in Swift"
  s.homepage         = "https://github.com/inbeom/Emo"
  s.license          = 'MIT'
  s.author           = { "Inbeom Hwang" => "hwanginbeom@gmail.com" }
  s.source           = { :git => "https://github.com/inbeom/Emo.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Emo/*.swift'
  s.resources = 'Emo/*.xib'

  s.frameworks = 'UIKit'
end
