# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
