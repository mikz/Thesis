require "cloud"

describe Cloud::CLI do
  before { Fog.mock! }
  after  { Fog.unmock! }

  context 'create task' do
    let(:task) { Cloud::CLI.all_tasks['create'] }

    subject { task }

    it { should be }

    context 'type option' do
      subject { task.options[:type] }
      its(:default){ should == "t1.micro" }
    end

    context 'key option' do
      subject { task.options[:key] }
      its(:default){ should == Socket.gethostname }
    end
  end

  context "cli" do
    let(:cli) { Cloud::CLI.new(['ami-id'], ["--key=#{key_pair.name}", "--type=t1.mini"]) }
    let(:server) { cli.invoke(:create) }
    let(:null_shell) { double("shell").as_null_object }

    let(:connection) { Fog::Compute::AWS.new(aws_access_key_id: ENV["AWS_KEY"], aws_secret_access_key: ENV["AWS_SECRET"], region: "eu-west-1") }
    let(:key_pair) { connection.key_pairs.create(name: "hostname") }

    before { Thor::Base.shell = null_shell }
    after { key_pair.destroy }

    before { ENV["AWS_KEY"], ENV["AWS_SECRET"] = "key", "secret" }
    after  { ENV["AWS_KEY"] = ENV["AWS_SECRET"] = nil }

    subject { cli }

    it 'returns fog server' do
      cli.create('ami-id').should be_kind_of(Fog::Compute::AWS::Server)
    end

    context "server" do
      subject { server }

      its(:key_name) { should == key_pair.name }
      its(:image_id) { should == "ami-id" }
      its(:flavor_id) { should == "t1.mini" }
    end

    context "output" do
      let(:stdout) { StringIO.new }
      let(:output) { server && stdout.string }
      let(:stub_shell) { null_shell.stub(:say){ |*args| stdout.puts *args } && null_shell }

      before { Thor::Base.shell = stub_shell }

      subject { output }

      it { should match(/started ami-id/) }
      it { should match(/t1\.mini/) }
    end
  end
end
