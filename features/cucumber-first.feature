Feature: Cucumber fun on Friday first BDD test
  Everybody wants to know when it's cucumber fun time

  Scenario: Sunday isn't Cucumber day
    Given today is Sunday
    When I ask whether it's Cucumber day yet
    Then I should be told "No way!"