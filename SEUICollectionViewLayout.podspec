Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "SEUICollectionViewLayout"
  s.version      = "0.1.0"
  s.summary      = "A base collection view layout that simplifies drawing/animation of sup/decoration views."

  s.homepage     = "http://github.com/bnickel/SEUICollectionViewLayout"
  s.license      = "MIT"
  s.author             = { "Brian Nickel" => "bnickel@stackexchange.com" }

  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/bnickel/SEUICollectionViewLayout.git", :tag => "v#{s.version}" }

  s.source_files  = "SEUICollectionViewLayout/SEUICollectionViewLayout"
  s.public_header_files = "SEUICollectionViewLayout/SEUICollectionViewLayout/*.h"
  s.framework  = "UIKit"
  s.requires_arc = true

end
