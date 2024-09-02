Pod::Spec.new do |spec|

  spec.name         = "ValifySDK"
  spec.version      = "1.0.0"
  spec.summary      = "We provide a face recognition feature 🚀"
  spec.homepage     = "https://github.com/peterrsamir/ValifySDK"
  spec.license      = "MIT"
  spec.author       = { "Peter" => "peterrsamir@gmail.com" }
  spec.platform     = :ios, "13.0"
  spec.swift_version = "5.0"
  spec.static_framework = true
  # Pointing to the specific branch
  spec.source       = { :git => "https://github.com/peterrsamir/ValifySDK.git", :branch => "dev/podspec" }
  
  # Source files relative to the repository root
  spec.source_files = "ValifySDK/**/*.{swift}"
  
  # Dependencies
  spec.dependency "GoogleMLKit/FaceDetection"
  
  # Frameworks
  spec.frameworks = "AVFoundation"

  # ARC
  spec.requires_arc = true

end
