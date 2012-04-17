require 'cloud'

describe 'task' do
  let(:tasks) { Cloud::CLI.all_tasks }

  it { tasks.should include('create', 'list', 'destroy') }

  context 'create' do
    let(:task) { tasks['create'] }
    subject { task }

    context 'options' do
      its(:options) { should include(:key, :type) }

      context 'key option' do
        subject { task.options[:key] }
        its(:default) { should == Socket.gethostname }
      end

      context 'type option' do
        subject { task.options[:type] }
        its(:default) { should == 't1.micro' }
      end
    end
  end

end
