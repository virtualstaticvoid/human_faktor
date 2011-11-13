class DemoRequestSystemMailer < Struct.new(:demo_request_id)
  
  def perform()
  
    demo_request = DemoRequest.find(demo_request_id)
    
    # send email to support
    SupportMailer.demo_request(demo_request).deliver
    
  end
  
end
