@announce
Feature:
  As player I should be able to win the game

  Background:
    * I run `adventura` interactively
    * type "Michal"

  Scenario: Win the game
    * type "go east"

    * type "pick knife"
    * type "pick uzi"
    * type "use knife on uzi"

    * type "go west"
    * type "give uzi to dwarf"
    * see "Thank you for this awesome UZI"

    * type "go to the castle"

    * type "use fountain"
    * see "You feel stronger!"

    * type "pick sword"

    * type "go to the cellar"

    * type "use sword on hole for sword"
    * see "Looks like you killed dragon"

    * type "go upstairs"
    * see "You are at: bedroom"

    * type "wake princess"
    * see "Michal, You won the game!"
