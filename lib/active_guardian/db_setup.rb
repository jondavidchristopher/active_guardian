require 'active_record'
require 'securerandom'

module ActiveGuardian
  module DbSetup
    def self.create_custom_db_users
      table_manager_password = ENV['TABLE_MANAGER_PASSWORD'] || SecureRandom.hex
      read_only_password = ENV['READ_ONLY_PASSWORD'] || SecureRandom.hex

      if ENV['TABLE_MANAGER_PASSWORD'].nil?
        puts "TABLE_MANAGER_PASSWORD not set. Generated password: #{table_manager_password}"
      end

      if ENV['READ_ONLY_PASSWORD'].nil?
        puts "READ_ONLY_PASSWORD not set. Generated password: #{read_only_password}"
      end

      ActiveRecord::Base.connection.execute("""
        DO $$
        BEGIN
          -- Create user with create and modify table privileges
          IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'table_manager') THEN
            CREATE USER table_manager WITH PASSWORD '#{table_manager_password}';
            GRANT CREATE, ALTER ON DATABASE #{ActiveRecord::Base.connection.current_database} TO table_manager;
          END IF;

          -- Create user with no delete privileges
          IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'read_only_user') THEN
            CREATE USER read_only_user WITH PASSWORD '#{read_only_password}';
            GRANT CONNECT ON DATABASE #{ActiveRecord::Base.connection.current_database} TO read_only_user;
            REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM read_only_user;
            ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE DELETE ON TABLES FROM read_only_user;
            -- Revoke ability to change roles from read_only_user
            REVOKE CREATE, ALTER, DROP ON ALL TABLES IN SCHEMA public FROM read_only_user;
            REVOKE USAGE, CREATE ON SCHEMA public FROM read_only_user;
            REVOKE ALL PRIVILEGES ON pg_roles FROM read_only_user;
          END IF;
        END $$;
      """)
    end
  end
end

# Set table_manager as the user for all migrations
module ActiveGuardian
  class Railtie < Rails::Railtie
    rake_tasks do
      Rake::Task['db:migrate'].enhance do
        ActiveRecord::Base.establish_connection(
          ActiveRecord::Base.connection_db_config.configuration_hash.merge(
            username: 'table_manager',
            password: ENV['TABLE_MANAGER_PASSWORD'] || 'table_manager_password'
          )
        )
      end
    end

    initializer 'custom_ar_migrations.set_default_user' do
      ActiveRecord::Base.establish_connection(
        ActiveRecord::Base.connection_db_config.configuration_hash.merge(
          username: 'read_only_user',
          password: ENV['READ_ONLY_PASSWORD'] || 'read_only_password'
        )
      )
    end
  end
end