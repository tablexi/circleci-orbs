# circleci-orbs

A collection of standard Table XI CircleCI jobs/commands

https://circleci.com/orbs/registry/orb/tablexi/standard

## What do these orbs provide

By including the `tablexi/standard` orb, you can use the common jobs/commands which are in use in many of our projects.

By using orbs, any improvements/learnings which we make on one project, can be more easily distributed to the other projects by way of upgrading the orb definition, and incrementing the in-use orb version on the various projects.

These orbs provide the following Jobs:

- `check_db_schema`: check to ensure that we can migrate from scratch and end up with the schema.rb
- `rubocop`: run the rubocop command
- `bundle_audit`: run the bundle-audit command
- `haml_lint`: run the haml-lint command
- `rspec`: Run Rspec after waiting for db and loading schema
- `teaspoon`: Run teaspoon after waiting for db and loading schema

These orbs provide the following commands:

- `wait_for_other_builds`: Ensure no earlier numbered job (of this branch) is running
- `wait_for_db`: Wait for the database to be ready to accept connections
- `load_db_schema`: Load the database schema, no matter the db type

## Using these orbs

To use these orbs, you first need to declare the orbs:
```yaml
version: 2.1
orbs:
  tablexi: tablexi/standard@0.0.5
```

You also must enable "Build Processing" within the CircleCI "Advanced Settings" tab.

Then you can specify the individual steps within your workflows:
```yaml
workflows:
  version: 2
  build_test_deploy:
    jobs:
      - build
      - tablexi/rspec:
          executor:
            name: my_executor
          requires:
            - build
      - tablexi/rubocop:
          executor:
            name: my_executor
          requires:
            - build
      - release_stage:
          requires:
            - tablexi/rspec
            - tablexi/rubocop
          filters:
            only:
              - develop
```

## Using a Mysql Database

The rspec and check_db_schema jobs by default wait for a postgres db to be available.
If you are running on a mysql database, pass the `mysql_db_type: true` parameter.

E.g.
```
- tablexi/check_db_schema:
    executor:
      name: my_executor
    mysql_db_type: true
    requires:
      - build
```

## Adjusting parallelism

The rspec job runs with parallelism 1 by default.
If you want to increase the parallelism, you can set it as a parameter.
E.g.

```
- tablexi/rspec:
    executor:
      name: my_executor
    mysql_db_type: true
    parallelism: 4
    requires:
      - build
```

## Validating your configuration

We recommend installing the `circleci` command-line tool.

    brew install circleci

So you can validate if your usage of orbs is correct, without having to check-in your config file.

    circleci config validate .circleci/config.yml

## What is each job, and how to use it

### check_db_schema

Check to ensure that we can migrate from scratch and end up with the schema.rb.

This takes an optional parameter of `mysql_db_type`

### rubocop

Run the rubocop command with the default `.rubocop.yml` configuration file

### bundle_audit

Run the bundle-audit command. This checks the ruby-advisory-db for any gems
which have known security issues, and fails the job if any exist.

Some project have gems in use which have known issues, but we have examined
the security bulletin and determined that we are NOT susceptible to the problem.

We can create a `.bundlerauditignore` which specifies the CVEs which we should ignore
(one per line).

### haml_lint

Run the haml-lint command to check the haml for formatting guidelines

### rspec

Run Rspec after waiting for db and loading schema.

This takes an optional parameter of `mysql_db_type`, and `parallelism`.
This takes an optional parameter of `store_screenshots`, which will allow access to screenshots of failed CI runs.
This takes an optional parameter of `report_coverage` which will use the (report_coverage)[https://github.com/rdunlop/codeclimate_circle_ci_coverage] gem to send rspec coverage results to CodeClimate.

### teaspoon

Run teaspoon after waiting for db and loading schema.

This takes an optional parameter of `mysql_db_type`


## Using the `wait_for_other_builds` command

The `wait_for_other_builds` command can be used in a joqb in order to ensure that there are no earlier builds running in CI when this build is running.

This can help deal with resource constraints such as deploying to a common server.

The `wait_for_other_builds` command uses the CircleCI API in order to see whether any lower-numbered jobs are executing on this branch.

In order to accomplish this:
1) Create an API Token from `https://circleci.com/gh/tablexi/<project>/edit#api`
  - On the "API Permissions" page
  - Choose "Create Token"
  - Choose "Scope: "Build Artifact"
  - set the "Token Label" to anything you want.
2) Copy the value of the API token created above
3) In the Environment Variables page (`https://circleci.com/gh/tablexi/<project>/edit#env-vars`)
  - Choose "Add Variable"
  - Name: "CIRCLE_TOKEN"
  - Value: <copied from previous step>

### Example use of `wait_for_other_builds`

```
release_stage:
  executor: my_executor
  steps:
    - attach_workspace:
        at: ~/tmp

    - tablexi/wait_for_other_builds

    - run: bundle exec cap stage deploy
```

### Troubleshooting common errors

If you have an error like

```jq: error (at <stdin>:0): Cannot index string with string "build_num"```

You probably need to recreate your `CIRCLE_TOKEN` API token.

Be sure that it's set with the correct permissions.


## Example

A full example:
```yaml
version: 2.1
orbs:
  tablexi: tablexi/standard@0.0.5
executors:
  my_executor:
    # The working directory is important, so that we
    # install/cache everything relative to that location
    working_directory: ~/tmp
    docker:
      - image: circleci/ruby:2.5.1-node
        environment:
          RAILS_ENV: test
          PGHOST: localhost
          PGUSER: ubuntu
          # Bundle paths are necessary so that the gems are installed within the workspace
          # otherwise, they are installed in /usr/local
          BUNDLE_PATH: ~/tmp/vendor/bundle
          BUNDLE_APP_CONFIG: ~/tmp/vendor/bundle
      - image: circleci/postgres:9.4.12-alpine
        environment:
          POSTGRES_USER: ubuntu
          POSTGRES_PASSWORD: ""

workflows:
  version: 2
  build_test_deploy:
    jobs:
      - build
      - tablexi/rspec:
          executor:
            name: my_executor
          requires:
            - build
      - tablexi/rubocop:
          executor:
            name: my_executor
          requires:
            - build
      - tablexi/bundle_audit:
          executor:
            name: my_executor
          requires:
            - build
      - tablexi/haml_lint:
          executor:
            name: my_executor
          requires:
            - build
      - tablexi/check_db_schema:
          executor:
            name: my_executor
          requires:
            - build
      - release_stage:
          requires:
            - tablexi/rspec
            - tablexi/rubocop
            - tablexi/bundle_audit
            - tablexi/haml_lint
            - tablexi/check_db_schema
          filters:
            branches:
              only:
                - develop
      - release_prod:
          requires:
            - tablexi/rspec
            - tablexi/rubocop
            - tablexi/bundle_audit
            - tablexi/haml_lint
            - tablexi/check_db_schema
          filters:
            branches:
              only:
                - master
```

## Upgrade Guide

If you are upgrading from an existing CircleCI 2.0 config file, these are some of the steps that you'll want to take:

1. Enable "Build Processing" within the CircleCI "Advanced Settings" tab.
1. Replace your `references` with executors
  - Old Style:
```
references:
  default_job_config: &default_job_config
    # The working directory is important, so that we
    # install/cache everything relative to that location
    working_directory: ~/tmp
    docker:
      - image: circleci/ruby:2.3.7-node-browsers-legacy
        environment:
          RAILS_ENV: test
          # Bundle paths are necessary so that the gems are installed within the workspace
          # otherwise, they are installed in /usr/local
          BUNDLE_PATH: ~/tmp/vendor/bundle
          BUNDLE_APP_CONFIG: ~/tmp/vendor/bundle
jobs:
  build:
    <<: *default_job_config
    steps:
      - checkout
```
  - New Style:
```
executors:
  my_executor:
    # The working directory is important, so that we
    # install/cache everything relative to that location
    working_directory: ~/tmp
    docker:
      - image: circleci/ruby:2.3.7-node-browsers-legacy
        environment:
          RAILS_ENV: test
          # Bundle paths are necessary so that the gems are installed within the workspace
          # otherwise, they are installed in /usr/local
          BUNDLE_PATH: ~/tmp/vendor/bundle
          BUNDLE_APP_CONFIG: ~/tmp/vendor/bundle
jobs:
  build:
    executor: my_executor
    steps:
      - checkout
```

1. Replace existing rspec/rubocop/etc jobs with tablexi/circleci-orbs jobs
  - Old Style:
```
workflows:
  version: 2
  build_test_deploy:
    jobs:
      - build
      - rspec:
          requires:
            - build
      - release_stage:
          requires:
            - rspec
          filters:
            branches:
              only:
                - develop
```
  - New Style:
```
workflows:
  version: 2
  build_test_deploy:
    jobs:
      - build
      - tablexi/rspec: # NOTE
          executor:
            name: my_executor
          mysql_db_type: true
          requires:
            - build
      - release_stage:
          requires:
            - tablexi/rspec # NOTE
          filters:
            branches:
              only:
                - develop
```

1. Replace existing `shell` references with `run` references:
  - Old Style:
```
      - type: shell
        command: |
          bundle exec rspec --profile 10
```
  - New Style: **Note**: The indentation of `command` and command lines are also changed.
```
      - run:
          command: |
            bundle exec rspec --profile 10
```

1. Validate that your changes are valid. (optional step)

```
circleci config validate .circleci/config.yml
```

## Developing updates for this gem

There are 2 ways to validate and test changes to this orb.

### Publishing the orb as a dev version

To push the current code into the `dev` version online:

`circleci orb publish src/standard.yml tablexi/standard@dev:first`

You can then test/validate by using the orb in your app's `config.yml`:

```
orbs:
  tablexi: tablexi/standard@dev:first
```

### Using config packing to make it an inline orb
- Copy your app's `.circleci/config.yml` to `src/config.yml`
- Add `orbs`/`tablexi` keys to the top level of `src/standard.yml`:
  ```
  orbs:
    tablexi:
      description: "A set of standard steps which we use for projects at Table XI"
      ...
  ```
- To validate, run `circleci config pack src | circleci config validate -`

More info:
- https://circleci.com/docs/2.0/orb-author/#writing-inline-orbs
- https://circleci.com/docs/2.0/local-cli/#packing-a-config
- https://circleci.com/docs/2.0/testing-orbs/#expansion-testing

## Publishing new versions of the orbs

The `circleci` command-line tool is used to publish versions of the orbs.

All Table XI members can publish development versions of the orbs.

To publish production-versions of the orbs, you must be a TXI Admin.

For more details: https://github.com/CircleCI-Public/config-preview-sdk/blob/master/docs/orbs-authoring.md

Before publishing, please consider updating the CHANGELOG.md.

Command to publish the current `dev` version:

`circleci orb publish promote tablexi/standard@dev:first patch`
