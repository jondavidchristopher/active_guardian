# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]
### Added
- Initial release of the ActiveGuardian gem.
- PostgreSQL triggers for enforcing read-only columns.
- Support for setting up `table_manager` and `read_only_user` database users during `db:prepare`.
- Environment variable support for database user passwords, with secure generation if not provided.
- Minitest tests for validating read-only column behavior, user roles, and trigger enforcement.

## [0.1.0] - 2024-10-15
### Added
- Initial version of the ActiveGuardian gem.
- Custom migrations that support `allow_update: true` or `false` to control column mutability.
- PostgreSQL-specific features for enhanced security and role separation.
- Custom database users (`table_manager` and `read_only_user`) with different permission levels.
- Integration with Rails' Active Record migrations to enhance security.

