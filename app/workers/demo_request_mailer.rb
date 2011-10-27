class DemoRequestMailer < Struct.new(:demo_request_id)
  
  def perform()
  
    demo_request = DemoRequest.find(demo_request_id)
    
    # send demo request details email
    DemoRequestsMailer.request_demo(demo_request).deliver
    
    # send email to support
    SupportMailer.demo_request(demo_request).deliver
    
  end
  
end
