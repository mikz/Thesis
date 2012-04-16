@announce
Feature: Running the game

  Scenario: Run the game, type name and see prompt
    * I run `adventura` interactively
    * see "Your name is?"
    * type "Michal"
    * see ">"
