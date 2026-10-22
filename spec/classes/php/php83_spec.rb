# frozen_string_literal: true

require 'spec_helper'

describe 'profile_webserver_old::php::php83' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      if os_facts[:os]['release']['major'].to_i >= 8
        it { is_expected.to compile }
      else
        it { is_expected.to compile.and_raise_error(%r{php 8.3 requires}) }
      end
    end
  end
end
