Pod::Spec.new do |spec|

  spec.name         = "ValifySDK"
  spec.version      = "1.0.0"
  spec.summary      = "We provide a face recognition feature 🚀"
  spec.homepage     = "https://github.com/peterrsamir/ValifySDK"
  spec.license      = "MIT"
  spec.author       = { "Peter" => "peterrsamir@gmail.com" }
  spec.platform     = :ios, "13.0"
  
  spec.source       = { :git => "https://github.com/peterrsamir/ValifySDK.git", :tag => spec.version.to_s }
  spec.source_files = "ValifySDK/**/*.{swift}"
  
  # Dependencies
  spec.dependency "GoogleMLKit/FaceDetection"
  
  # Frameworks
  spec.frameworks = "AVFoundation"

  # ARC
  spec.requires_arc = true

end
