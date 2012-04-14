# features/example.feature

Feature: Example

  Background:
    When I have Example with value "value"

  Scenario:
    Then it should be truthy
     And it shouldn't be falsy
     And it's value should be "value"
