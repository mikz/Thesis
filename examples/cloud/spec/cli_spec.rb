require "cloud"

Fog::Mock.delay = 0

describe Cloud::CLI do
  before { Fog.mock! }
  after  { Fog.unmock! }
  after  { Fog::Mock.reset }

  let(:shell) { Thor::Base.shell.new }
  let(:stdout) { StringIO.new }
  let(:output) { stdout.string }
  before { shell.stub(:stdout) { stdout } }

  let(:key) { ENV["AWS_ACCESS_KEY_ID"] = 'key' }
  let(:secret) { ENV["AWS_SECRET_ACCESS_KEY"] = 'secret' }

  let(:connection) { Fog::Compute::AWS.new(aws_access_key_id: key, aws_secret_access_key: secret, region: "eu-west-1") }
  let(:key_pair) { connection.key_pairs.create(name: "hostname") }

  let(:task) {  Cloud::CLI.start(command,  shell: shell) }

  subject { task && output }

  context "creates server" do
    let(:command) { %W(create ami-id --key=#{key_pair.name} --type=t1.mini) }

    it("prints ami of server") { should match('started ami-id') }
    it("prints type of server") { should match('t1.mini') }
  end

  context 'list servers' do
    let(:command) { %W(list) }

    let(:custom) { connection.servers.create(image_id: 'custom-ami') }
    let(:other) { connection.servers.create(image_id: 'other-ami') }

    before do
      custom.wait_for(&:ready?)
      other.wait_for(&:ready?)
    end

    it("prints ami of servers") do
      should match(custom.image_id)
      should match(other.image_id)
    end

    it "prints dns of servers" do
      should match(custom.dns_name)
      should match(other.dns_name)
    end
  end

  context "destroy server" do
    let(:command) { %W(destroy #{server.id}) }
    let(:server) { connection.servers.create(image_id: 'server-ami') }

    before { server.wait_for(&:ready?) }

    it "prints message" do
      should match("Server #{server.id} will be destroyed")
    end

    context "which doesn't exist" do
      let(:command) { %w(destroy some-id) }

      it "prints message" do
        should match("No server with id some-id found")
      end
    end
  end

  context 'create task' do
    let(:task) { Cloud::CLI.all_tasks['create'] }

    context 'type option' do
      subject { task.options[:type] }
      its(:default){ should == "t1.micro" }
    end

    context 'key option' do
      subject { task.options[:key] }
      its(:default){ should == Socket.gethostname }
    end
  end

end
