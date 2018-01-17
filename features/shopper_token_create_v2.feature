Feature: Shopper Token

Scenario Outline: .create
    When I generate a shopperToken with contact identifier type '<contactIdentifierType>' and identifer '<contactIdentifierValue>' and validity period '<validityPeriod>'
    Then the contact identifier of type '<decodedType>' should be '<decodedContactIdentifier>' and the validity period should be '<validity>'
    And the token should include 'iss: MERCHANT'

    Examples:
        | contactIdentifierType    | contactIdentifier          | validity | decodedType | decodedContactIdentifier     | decodedValidity |
        | shopperId                | this-is-a-shopper-id       |    12    | shi | this-is-a-shopper-id         |   12            |
        | contactId                | this-is-a-contact-id       |    12    | coi | this-is-a-contact-id         |   12            |
        | userSuppliedId           | this-is-a-user-supplied-id |    12    | cui | this-is-a-user-supplied-id   |   12            |

