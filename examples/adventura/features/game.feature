@announce
Feature:
  Background:
    * I run `adventura` interactively
    * see "Your name is?"
    * type "Michal"

  Scenario:
    * see "Welcome to Adventura"
    * see ">"

  Scenario: help
    * type "help"
    * see "where can I go?"
    * see "go to the"
    * see "look around"
    * see "talk to"
    * see "exit"

  Scenario: Items
    * type "look around"
    * see "You don't see any items"

    * type "go east"
    * type "look around"
    * see:
    """
    You see following items:
    an old army knife
    """

    * type "pick"
    * see "What do you want to pick?"
    * type "knife"
    * see "You picked up an old army knife"

    * type "pick knife"
    * see "There is no knife"

    * type "pick rock"
    * see "You cannot pick rock"

  Scenario: Use
    * type "go east"
    * type "use knife"
    * see "there is no way how you can use an old army knife"

    * type "pick knife"
    * type "use knife"
    * see "there is no way how you can use an old army knife"

    * type "use knife on uzi"
    * see "You sucessfully combined knife and uzi"

  Scenario: Locked room
    * type "go to the castle"
    * see "bridge is locked!"

  Scenario: Description
    * type "describe bridge"
    * see "long, long bridge above the lake"

    * type "describe rocky road"
    * see "Rocky road to cave on west"

  Scenario: Follow
    * type "follow rocky road"
    * see "Can't go there!"

    * type "follow tunnel"
    * see "You are at: cave"

    * type "follow tunnel"
    * see "You are at: cave"

    * type "follow road"
    * see "You are at: lake"

  Scenario: Talk
    * type "talk to dwarf"
    * see "You don't have what I want!"

    * type "go east"
    * type "pick knife"
    * type "pick uzi"

    * type "go west"
    * type "talk to dwarf"
    * see "You don't have what I want!"

    * type "use knife on uzi"
    * type "talk to dwarf"
    * see "Ah! Give it to me!"

    * type "give uzi to dwarf"
    * see "Thank you for this awesome UZI"

    * type "talk to dwarf"
    * see "Thanks! See you soon!"
