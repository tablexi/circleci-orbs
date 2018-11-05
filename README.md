# circleci-orbs

A collection of standard Table XI CircleCI jobs/commands

## Developing updates for this gem

To push the current code into the `dev` version online:

`circleci orb publish .circleci/config.yml tablexi/standard@dev:first`

## Publishing new versions of the orbs

The `circleci` command-line tool is used to publish versions of the orbs.

All Table XI members can publish development versions of the orbs.

To publish production-versions of the orbs, you must be a TXI Admin.

For more details: https://github.com/CircleCI-Public/config-preview-sdk/blob/master/docs/orbs-authoring.md

Command to publish the current `dev` version:

`circleci orb publish promote tablexi/standard@dev:first patch`

## Using these orbs

To use these orbs, you first need to declare the orbs:
```yaml
version: 2.1
orbs:
  tablexi: tablexi/standard@0.0.1
```

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

A full example:
```yaml
version: 2.1
orbs:
  tablexi: tablexi/standard@0.0.1
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

## Using the `wait_for_other_builds` command

The `wait_for_other_builds` command can be used in order to ensure that there are no earlier builds running in CI when this build is running.

This can help deal with resource constraints such as deploying to a common server.

In order to accomplish this, the `wait_for_other_builds` command uses the CircleCI API in order to see whether any lower-numbered jobs are executing on this branch.

To do this, you must first specify a `CIRCLE_TOKEN` in the project's Environment Variables, and set this to an "API Key" that you have created in the Circle CI UI.
