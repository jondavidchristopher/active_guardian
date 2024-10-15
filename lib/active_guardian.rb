require "active_guardian/version"
require 'rails/generators/active_record'
require 'securerandom'

module ActiveGuardian
  class Railtie < Rails::Railtie
    initializer 'custom_ar_migrations.initialize' do
      ActiveSupport.on_load(:active_record) do
        require 'custom_ar_migrations/active_record_migration'
        require 'custom_ar_migrations/db_setup'
      end

      # Hook into db:prepare to add custom database users
      Rake::Task['db:prepare'].enhance do
        ActiveGuardian::DbSetup.create_custom_db_users
      end
    end
  end
end