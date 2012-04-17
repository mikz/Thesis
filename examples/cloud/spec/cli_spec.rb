require "cloud"

Fog::Mock.delay = 0

describe Cloud::CLI do
  before { Fog.mock! }
  after  { Fog.unmock! }
  # reset all created servers, keys and other stuff
  after  { Fog::Mock.reset }

  # we need to capture output of task
  # stubbing stdout of shell and getting string from it
  # other solution would be to capture real $stdout
  let(:shell) { Thor::Base.shell.new }
  let(:stdout) { StringIO.new }
  let(:output) { stdout.string }
  before { shell.stub(:stdout) { stdout } }

  # we need to set ENV variables, because app uses them
  let(:key) { ENV["AWS_ACCESS_KEY_ID"] = 'key' }
  let(:secret) { ENV["AWS_SECRET_ACCESS_KEY"] = 'secret' }

  # we also need own connection to AWS
  let(:connection) { Fog::Compute::AWS.new(aws_access_key_id: key, aws_secret_access_key: secret, region: "eu-west-1") }

  # and this is how task is invoked (with own shell as config option)
  let(:task) {  Cloud::CLI.start(command,  shell: shell) }

  # run the task and return output
  subject { task && output }

  context "creates server" do
    let(:key_pair) { connection.key_pairs.create(name: "hostname") }
    let(:command) { %W(create ami-id --key=#{key_pair.name} --type=t1.mini) }

    it("prints ami of server") { should match('started ami-id') }
    it("prints type of server") { should match('t1.mini') }
  end

  context 'list servers' do
    let(:command) { %W(list) }

    let!(:custom) { connection.servers.create(image_id: 'custom-ami').reload }
    let!(:other) { connection.servers.create(image_id: 'other-ami').reload }

    it "prints ami of servers" do
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

    let!(:server) { connection.servers.create(image_id: 'server-ami').reload }

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

end
