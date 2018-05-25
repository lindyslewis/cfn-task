require 'aws-sdk'
#require 'rspec'

class Pipeline

  #@elb_url = nil

  def initialize(stackname:'llewis-cfn-elb-asg-stack')
    @cloudformation = Aws::CloudFormation::Client.new()
    @stackname = stackname
  end

  def deploy

    cloudformation_body_string = ''

    file = File.new('llewis-cfn.yaml', 'r')
    file.each_line do |line|
      cloudformation_body_string += line
    end

    puts "Creating stack: #{@stackname}"

    #Call the create_stack method to create a stack
    response = @cloudformation.create_stack({
      stack_name: @stackname,
      template_body: cloudformation_body_string
    })

    #@cloudformation.wait_until(:stack_create_complete, stack_name: @stackname)

    puts "Stack created: #{@stackname}"
    #self.wait_until_elb_ready
    #sleep 20
  end
=begin
  def get_elb_url
    response = @cloudformation.describe_stacks({stack_name: @stackname})

    filtered_outputs = response.stacks[0].outputs.select do |output|
      output.output_key == 'URL'
    end
    url_output = filtered_outputs[0]
    @elb_url = url_output.output_value
  end

  def wait_until_elb_ready
    response = @cloudformation.describe_stacks({stack_name: @stackname})
    filtered_outputs = response.stacks[0].outputs.select do |output|
      output.output_key == 'ELBName'
    end
    elb_output = filtered_outputs[0]
    @elb_name = elb_output.output_value
    puts "Waiting for instances to register with elb: #{@elb_name}"
    elb = Aws::ElasticLoadBalancing::Client.new
    elb.wait_until(:any_instance_in_service, load_balancer_name: @elb_name)
    puts "Instances regsitered to elb: #{@elb_name}"
  end

  def run_acceptance_test
    RSpec::Core::Runner.run(['spec/acceptance_test_spec.rb'])
  end
=end
  def cleanup
    puts "Deleting stack: #{@stackname}"
    response = @cloudformation.delete_stack({
      stack_name: @stackname
    })
    @cloudformation.wait_until(:stack_delete_complete, stack_name: @stackname)
    puts "Stack deletion complete: #{@stackname}"
  end
end


def run_cli

   def usage
     puts 'usage: pipeline.rb command '
     exit 1
   end

   if ARGV.length != 1
    usage
   end

   user_input_arg = ARGV[0]
   commands = ['deploy', 'test', 'cleanup']

   if !commands.include? user_input_arg
    usage
   end

   cfn_pipeline = Pipeline.new

   if user_input_arg == 'deploy'
    cfn_pipeline.deploy
    #elb_url = cfn_pipeline.get_elb_url
    #puts "Almost ready..."
    #sleep 20
    #puts "Running acceptance tests against #{elb_url}"
    #mini_project_pipeline.run_acceptance_test
    #puts "Acceptance tests complete. Navigate to: #{elb_url}"
   end

   if user_input_arg == 'cleanup'
    cfn_pipeline.cleanup
   end

   #if user_input_arg == 'test'
    #cfn_pipeline.run_acceptance_test
   #end

end

run_cli
