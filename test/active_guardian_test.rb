require "test_helper"

equire 'test_helper'

class ActiveGuardianTest < ActiveSupport::TestCase
  def setup
    ActiveRecord::Base.connection.create_table(:test_entities, force: true) do |t|
      t.string :name, null: false
      t.string :email, null: false, unique: true, allow_update: false
      t.integer :age, allow_update: true
    end
    @test_entity = TestEntity.create!(name: 'John Doe', email: 'john@example.com', age: 30)
  end

  def teardown
    ActiveRecord::Base.connection.drop_table(:test_entities, if_exists: true)
  end

  test 'that it has a version number' do
    refute_nil ::ActiveGuardian::VERSION
  end

  test 'should prevent update to read-only column' do
    assert_raises(ActiveRecord::StatementInvalid, /Column "email" is read-only/) do
      @test_entity.update!(email: 'new_email@example.com')
    end
  end

  test 'should allow update to updatable column' do
    assert_nothing_raised do
      @test_entity.update!(age: 35)
    end
    assert_equal 35, @test_entity.reload.age
  end

  test 'should prevent update to explicitly read-only column using add_column' do
    ActiveRecord::Base.connection.add_column(:test_entities, :status, :string, allow_update: false)
    @test_entity.update_column(:status, 'active') # Setting the value directly, bypassing validations

    assert_raises(ActiveRecord::StatementInvalid, /Column "status" is read-only/) do
      @test_entity.update!(status: 'inactive')
    end
  end

  test 'should allow update to explicitly allowed column using add_column' do
    ActiveRecord::Base.connection.add_column(:test_entities, :nickname, :string, allow_update: true)
    @test_entity.update!(nickname: 'JD')
    assert_equal 'JD', @test_entity.reload.nickname
  end

  test 'should prevent role change by read_only_user' do
    ActiveRecord::Base.connection.create_table(:test_entities, force: true) do |t|
      t.string :name, null: false
      t.string :role, default: 'guest'
    end
    read_only_entity = TestEntity.create!(name: 'Read Only', role: 'guest')
    ActiveRecord::Base.connection.execute("SET SESSION AUTHORIZATION 'read_only_user'")

    assert_raises(ActiveRecord::StatementInvalid, /permission denied/) do
      read_only_entity.update!(role: 'admin')
    end
  ensure
    ActiveRecord::Base.connection.execute("RESET SESSION AUTHORIZATION")
  end

  test 'validate PostgreSQL user roles' do
    roles = ActiveRecord::Base.connection.execute("SELECT rolname FROM pg_roles WHERE rolname IN ('table_manager', 'read_only_user')").map { |row| row['rolname'] }
    assert_includes roles, 'table_manager', 'Expected table_manager role to exist'
    assert_includes roles, 'read_only_user', 'Expected read_only_user role to exist'
  end

  test 'validate PostgreSQL trigger enforcement' do
    # Verify that the read-only triggers have been created for the required columns
    triggers = ActiveRecord::Base.connection.execute("SELECT tgname FROM pg_trigger WHERE tgname LIKE 'trigger_read_only_%'").map { |row| row['tgname'] }
    assert_includes triggers, 'trigger_read_only_test_entities_email', 'Expected trigger for read-only email column to exist'
  end
end
