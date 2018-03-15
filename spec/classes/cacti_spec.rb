require 'spec_helper'

describe 'cacti', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os} " do
      let :facts do
        facts
      end

      let :required_params do
        {
          'database_root_pass' => 'root_password',
          'database_pass'      => 'cacti_password'
        }
      end

      context 'with required params SET' do
        let :params do
          required_params
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('cacti::params') }
        it { is_expected.to contain_class('cacti::install').that_comes_before('Class[cacti::mysql]') }
        it { is_expected.to contain_class('cacti::mysql').that_comes_before('Class[cacti::config]') }
        it { is_expected.to contain_class('cacti::config').that_comes_before('Class[cacti::service]') }
        it { is_expected.to contain_class('cacti::service') }

        context 'and configure_epel => true' do
          let :params do
            required_params
          end

          it { is_expected.to contain_class('epel').that_comes_before('Package[cacti]') }
        end # context configure_epel => true

        context 'and configure_epel => false' do
          let :params do
            required_params.merge!('configure_epel' => false)
          end

          it { is_expected.not_to contain_class('epel') }
        end # context configure_epel => false

        context 'and configure_php => true' do
          it do
            is_expected.to contain_package('php').with(
              'ensure' => 'present',
              'before' => 'Package[cacti]'
            )
          end

          it do
            is_expected.to contain_class('php').with(
              'notify'   => '[]',
              'settings' => {
                'Date/date.timezone' => :undef
              }
            )
          end
        end # context configure_php => true

        context 'and configure_php => false' do
          let :params do
            required_params.merge!('configure_php' => false)
          end

          it { is_expected.not_to contain_package('php') }
          it { is_expected.not_to contain_class('php') }
        end # context configure_php => false
      end # context required params SET

      context 'with required params UNSET' do
        it { is_expected.not_to compile.with_all_deps }
      end # context required params UNSET
    end # context on os
  end # on_supported_os.each
end # describe cacti class
