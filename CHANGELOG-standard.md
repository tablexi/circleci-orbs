# Changelog
All notable changes to the src/standard.yml will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

## [0.0.12] - 2023-03-16

- Add `apt install -y ca-certificates` before installing `tzdata`
- Upgrade to `circleci/browser-tools@1.4.1`

## [0.0.11] - 2022-02-03

- Add install_bundler step to install correct version of bundler before running any bundler commands. Leverage this in all other jobs where we use bundler
- Add option to install browsers before running rspec commands
- Add option to install phantomjs before running rspec commands
- Update load_db_schema step to also install mysql libraries and create the database before loading schema

## [0.0.10] - 2021-08-23

- Add `check_annotate` job, to help ensure that annotations stay up to date on projects
- Update `load_db_schema` task to handle changes to the apt-get repository which removed some needed libraries.

## [0.0.9] - 2020-09-03

- Fix typo in indentation of new tmp/screenshots artifact directive

## [0.0.8] - 2020-09-02

- Remove default_executor from orb. This will force all users to specify an executor (which is a good thing)
- Store tmp/screenshots from rspec into artifacts directory by default

## [0.0.7] - 2019-08-02

- update mysql-client target to be default-mysql-client, so that more linux distros can find it.

## [0.0.6] - 2019-07-24

- Remove `ignored_cves` option, replacing it with `.bundlerauditignore` file support.

## [0.0.5] - 2019-07-23

- Allow specifying `ignored_cves` argument to `bundle_audit` job
- Update bundle-audit vulnerabilities db before checking project

## [0.0.4] - 2019-05-14

### Changed

- Improved README documenting how to apply these changes to an existing project
- Perform apt-get update before trying to install mysql-client or postgres tools

## [0.0.3] - 2018-12-21

### Added

- Added COMMAND: tablexi/load_db_schema, to allow loading schema/structure
- Added JOB: tablexi/teaspoon, to run teaspoon specs

### Changed

- Enhanced JOB: tablexi/rspec, now takes an optional 'report_coverage' boolean, to send results to code climate with the 'report_coverage' tool

## [0.0.2] - 2018-11-12

### Added

- Added Upgrade guide to README (#6)
- Added capability for `check_db_schema` and `rspec` jobs to handle structure.sql schema dumps (#4)

### Changed

- Improved documentation

### Fixed

- Fixed publish `dev:first` command in README (#5)


## [0.0.1] - 2018-10-30

### Added

- Initial Release
- Added Job: check_db_schema
- Added Job: rubocop
- Added Job: bundle_audit
- Added Job: haml_lint
- Added Job: rspec
