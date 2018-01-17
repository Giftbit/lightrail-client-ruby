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
    * correctly applies the specified validity period '12'

Scenario: .create
    * includes 'iat'

Scenario: .create
    * includes 'iss: MERCHANT'



Scenario: .create
    When I generate a shopper token the decoded token should include /{"alg":"HS256"}/

    When I generate a shopper token with shopperId 'this-is-a-shopper-id', the decoded token should include
    """
    {"shi":"this-is-a-shopper-id","gui":"gooey","gmi":"germie"}
    """

    When I generate a shopper token with contactId 'this-is-a-contact-id', the decoded token should include
    """
    {"coi":"this-is-a-contact-id","gui":"gooey","gmi":"germie"}
    """



    When I generate a shopper token with contact identifier ''
