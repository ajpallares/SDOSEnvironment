@version = "1.1.0"
Pod::Spec.new do |spec|
  spec.platform     = :ios, '9.0'
  spec.name         = 'SDOSEnvironment'
  spec.authors      = 'SDOS'
  spec.version      = @version
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/SDOSLabs/SDOSEnvironment'
  spec.summary      = 'Librería para el manejo de variables de entorno'
  spec.source       = { :git => "https://github.com/SDOSLabs/SDOSEnvironment.git", :tag => "v#{spec.version}" }
  spec.framework    = ['Foundation']
  spec.requires_arc = true
  spec.swift_version = '5.0'

  spec.preserve_paths = "src/Scripts/*"
  spec.subspec 'SDOSEnvironment' do |s1|
    s1.preserve_paths = 'src/Classes/*'
    s1.source_files = ['src/Classes/*{*.m,*.h,*.swift}', 'src/Classes/**/*{*.m,*.h,*.swift}']
  end
  
  spec.dependency 'RNCryptor', '~> 5.0'

end
