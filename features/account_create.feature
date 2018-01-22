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


Scenario: Account.create with all data passed in from feature file
    * method requires parameters shopperId <this-is-a-shopper-id> and currency <ABC> and userSuppliedId <account-user-supplied-id>

   # * make GET call to <contacts?userSuppliedId=> using parameter shopperId and receive API response
   #  """
   #  {"contacts":[{"contactId":"this-is-a-contact-id"}]}
   #  """

   # * make GET call to <cards?cardType=ACCOUNT_CARD&contactId=''&currency=''> using parameters contactId and currency and receive API response
   # """
   # {"cards":[]}
   # """

   # * make POST call to </cards> using parameters contactId and currency and receive API response
   # """
   # {"card":{"cardId":"this-is-an-account-card-id", "contactId":"this-is-a-contact-id"}}
   # """




# REQUIRES SUPPORTING VARIABLE/JSON FILE

Scenario:
   # * creating an account with parameters 'shopperId', 'currency', and 'userSuppliedId', should result in calling the following API endpoints: 'get' 'contactsSearch' - receive 'contactsSearchOneResult', then 'get' 'accountCardsSearch' - receive 'accountCardsSearchNoResults', then 'post' 'cards' - receive 'accountCard'


    # ALTERNATIVE VERSION - ALSO REQUIRES SUPPORTING FILE

     * creating an account with <parameters> should result in calling <endpoints> with <httpMethod> and corresponding <jsonResponses>

        | parameters                                      | httpMethods    | endpoints                                              | jsonResponses                                                      |
        | shopperId, currency, userSuppliedId             | get, get, post | contactsSearch, accountCardsSearch, cards | contactsSearchOneResult, accountCardsSearchNoResults, accountCard |
        | contactId, currency, userSuppliedId             | get, get, post | contacts, accountCardsSearch, cards       | contactResult, accountCardsSearchNoResults, accountCard |
#        | userSuppliedId, currency, userSuppliedId | get, get, post | contactsSearch, accountCardsSearch, cards | contactsSearchOneResult, accountCardsSearchNoResults, accountCard |

