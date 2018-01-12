Feature: Create Account Card

Scenario:
    Given a Contact exists, no account in given currency
    When I pass in a shopperId, currency & userSuppliedId
    Then create a new Account

Scenario:
    Given a Contact with an Account in a given currency
    When I retrieve the Contact's Account card for that currency
    Then return the Account card

Scenario:
    Given I retrieve the Contact's Account card for that currency

Scenario:
    * retrieve account card by shopperId and currency

Scenario:
    * I can create an account with shopperId 'this-is-a-shopper-id' and currency 'ABC' and userSuppliedId 'this-is-a-user-supplied-id'