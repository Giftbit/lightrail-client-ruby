Feature: Account Card

Scenario:
    * I can create an account with shopperId 'this-is-a-shopper-id' and currency 'ABC' and userSuppliedId 'this-is-a-user-supplied-id'


Scenario:
    * handles json
    """
    {
        "transaction": {
            "transactionId": "transaction-ac11917b94c64c84b082c865b7"
        }
    }
    """


Scenario: .create
    * creates a new account given a shopperId 'this-is-a-shopper-id' & currency 'ABC'

Scenario: .create
    * creates a new account given a contactId 'this-is-a-contact-id' & currency 'ABC'


Scenario: .create - error handling
    * throws an error if no contactId or shopperId

Scenario: .create - error handling
    * throws an error if no currency

Scenario: .create - error handling
    * throws an error if no userSuppliedId


