# ActiveGuardian

ActiveGuardian is a Ruby on Rails gem that customizes Active Record migrations to enhance security and enforce immutability at the database level. This gem is specifically designed for PostgreSQL, providing strict controls over column-level updates and user permissions to ensure data integrity.

## Features

- **Column Immutability**: Automatically generate PostgreSQL triggers to enforce immutability for specified columns, making them read-only by default.
- **Custom Database Users**: Sets up two database users:
  - **table_manager**: A user with privileges to create and modify tables, used during migrations.
  - **read_only_user**: A user with restricted privileges, unable to delete data or modify certain database roles, used for the default application connection.
- **Enhanced Security**: Ensures that the `read_only_user` cannot modify database roles or perform destructive operations, minimizing potential risks.
- **Environment Variable Support**: User passwords can be set via environment variables, and if they are not provided, secure random passwords will be generated and output to the console.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_guardian'
```

And then execute:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install active_guardian
```

## Usage

ActiveGuardian integrates seamlessly with Rails' Active Record migrations. It customizes migration tasks to enforce immutability and sets up appropriate user roles.

### Setting Up Database Users

When you run `db:prepare`, ActiveGuardian will automatically create two database users if they do not already exist:

- **table_manager**: Used during migrations, with privileges to create and modify tables.
- **read_only_user**: Used by default for the Rails application, with restricted privileges.

Passwords for these users can be set via the following environment variables:

- `TABLE_MANAGER_PASSWORD`
- `READ_ONLY_PASSWORD`

If these environment variables are not set, secure random passwords will be generated, and their values will be printed to the console.

### Example Migration

By default, all new columns added with ActiveGuardian will be read-only. If you need a column to be updatable, you can specify `allow_update: true` in the migration.

```ruby
class AddUserDetails < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false, unique: true, allow_update: false  # Read-only by default
      t.integer :age, allow_update: true  # Updatable
    end
  end
end
```

### Custom User Roles

ActiveGuardian uses the `table_manager` user for running database migrations and the `read_only_user` for the default application connection. This separation ensures that the application cannot perform destructive operations such as dropping tables or deleting data, adding an extra layer of safety.

## Compatibility

ActiveGuardian is designed to work specifically with PostgreSQL. Other database systems are not supported at this time.

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/jondavidchristopher/active_guardian](https://github.com/yourusername/active_guardian). This project is intended to be a safe, welcoming space for collaboration.

## License

This gem is available as open-source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Acknowledgments

ActiveGuardian was inspired by the need to enforce strict database-level constraints, providing a more secure default setup for Rails applications using PostgreSQL.

