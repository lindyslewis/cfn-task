require 'aws-sdk'

class Pipeline

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

    @cloudformation.wait_until(:stack_create_complete, stack_name: @stackname)

    puts "Stack created: #{@stackname}"

  end

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
   end

   if user_input_arg == 'cleanup'
    cfn_pipeline.cleanup
   end

end

run_cli
