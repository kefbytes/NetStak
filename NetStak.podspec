Pod::Spec.new do |spec|
  spec.name         			= 'NetStak'
  spec.version     	 			= '1.0.0'
  spec.license      			= { :type => 'BSD' }
  spec.homepage     			= 'https://github.com/kefbytes/NetStak.git'
  spec.authors      			= { 'Kent Franks' => 'kent@kefbytes.com' }
  spec.summary      			= 'Simple Swift service layer'
  spec.source       			= { :git => 'https://github.com/kefbytes/NetStak.git', :tag => 'v1.0.0' }
  spec.source_files 			= 'NetStak/*.swift'
  spec.framework    			= 'Foundation'
  spec.swift_version			= '4.2'
  spec.ios.deployment_target	= '12.1'
  
end