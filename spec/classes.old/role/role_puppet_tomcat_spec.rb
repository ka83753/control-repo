require 'spec_helper'

describe 'role::puppet_tomcat' do

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "without any parameters" do
          it { is_expected.to compile.with_all_deps }
        end

      end
    end

end