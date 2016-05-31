

Pod::Spec.new do |s|

  s.name         = "YFLinkageScroll"
  s.authors	  = "xuyufang"
  s.version      = “1.0.2”
  s.summary      = "UIScrollView网易标签和管理”
  s.license 	  = "MIT"
  s.homepage	  = "https://github.com/yfGit"
  s.source	  = { :git => "https://github.com/yfGit/YFLinkageScroll.git", :tag => “1.0.2” }
  s.source_files = "YFLinkageScrollView/YFLinkageScrollView/YFView/*"
  s.framework    = 'Foundation', 'UIKit'
  s.platform     = :ios, '7.0'
  s.description  = <<-DESC 
			Fast encryption string, the current support for MD5 (16, 32), Sha1, Base64
 			DESC
  s.requires_arc = true
  
end
