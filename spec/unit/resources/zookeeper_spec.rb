require 'spec_helper'

describe 'zookeeper' do
  step_into :zookeeper
  platform 'ubuntu'

  context 'with default properties' do
    automatic_attributes['memory']['total'] = 2048

    recipe do
      zookeeper 'zookeeper' do
        use_java_cookbook false
      end
    end

    it { is_expected.to install_ark('zookeeper') }
  end

  context 'with pre-3.5.0 version' do
    recipe do
      zookeeper 'zookeeper' do
        version '3.4.9'
        use_java_cookbook false
      end
    end

    it do
      is_expected.to install_ark('zookeeper').with(
        url: 'http://archive.apache.org/dist/zookeeper/zookeeper-3.4.9/zookeeper-3.4.9.tar.gz'
      )
    end
  end
end
