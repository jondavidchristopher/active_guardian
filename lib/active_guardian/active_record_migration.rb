module ActiveGuardian
  module ActiveRecordMigration
    def create_table(table_name, **options, &block)
      # Custom logic here, for example, add default timestamps for every table:
      super(table_name, **options) do |t|
        block.call(t) if block_given?
        t.timestamps(null: false) unless options[:skip_timestamps]
      end
    end
  end

  module MigrationColumnOptions
    def column(name, type, **options)
      options = { allow_update: false }.merge(options)
      super(name, type, **options.except(:allow_update))
      set_read_only_trigger(name) if options[:allow_update] == false
    end

    def add_column(table_name, column_name, type, **options)
      options = { allow_update: false }.merge(options)
      super(table_name, column_name, type, **options.except(:allow_update))
      set_read_only_trigger(table_name, column_name) if options[:allow_update] == false
    end

    def change_column(table_name, column_name, type, **options)
      options = { allow_update: false }.merge(options)
      super(table_name, column_name, type, **options.except(:allow_update))
      set_read_only_trigger(table_name, column_name) if options[:allow_update] == false
    end

    private

    def set_read_only_trigger(table_name, column_name = nil)
      return unless column_name

      # Create a PostgreSQL trigger to enforce column immutability
      execute <<-SQL
        DO $$
        BEGIN
          IF NOT EXISTS (
            SELECT 1 FROM pg_trigger
            WHERE tgname = 'trigger_read_only_#{table_name}_#{column_name}'
          ) THEN
            CREATE OR REPLACE FUNCTION enforce_read_only_#{table_name}_#{column_name}() RETURNS TRIGGER AS $$
            BEGIN
              IF NEW.#{column_name} IS DISTINCT FROM OLD.#{column_name} THEN
                RAISE EXCEPTION 'Column "#{column_name}" is read-only';
              END IF;
              RETURN NEW;
            END;
            $$ LANGUAGE plpgsql;

            CREATE TRIGGER trigger_read_only_#{table_name}_#{column_name}
            BEFORE UPDATE ON #{table_name}
            FOR EACH ROW
            EXECUTE FUNCTION enforce_read_only_#{table_name}_#{column_name}();
          END IF;
        END $$;
      SQL
    end
  end
end

# Override the ActiveRecord::ConnectionAdapters::SchemaStatements#create_table
ActiveRecord::ConnectionAdapters::SchemaStatements.prepend(ActiveGuardian::ActiveRecordMigration)
ActiveRecord::ConnectionAdapters::TableDefinition.prepend(ActiveGuardian::MigrationColumnOptions)
ActiveRecord::ConnectionAdapters::AbstractAdapter.prepend(ActiveGuardian::MigrationColumnOptions)