Feature: Shopper Token

Scenario: generate
    * handles json
    """
    {
        "transaction": {
            "transactionId": "transaction-ac11917b94c64c84b082c865b7"
        }
    }
    """


Scenario: .create
    * generates a JWT with the supplied shopper_id 'this-is-a-shopper-id'

Scenario: .create
    * generates a JWT with the supplied contact_id 'this-is-a-contact-id'

Scenario: .create
    * generates a JWT with the supplied contact user_supplied_id 'this-is-a-user-supplied-id'

Scenario: .create
    * generates a JWT with the supplied validity period '12'

Scenario: .create
    * includes 'iat'

Scenario: .create
    * includes 'iss: MERCHANT'






Scenario: .create
    When I generate a shopper token with shopperId 'this-is-a-shopper-id', the decoded token should include
    """
    {"shi":"this-is-a-shopper-id","gui":"gooey","gmi":"germie"}
    """
