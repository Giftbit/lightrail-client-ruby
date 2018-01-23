Feature: Account Card


@account_creation

Scenario: Create by shopperId
When a contact exists but has no account: requires minimum parameters [shopperId, currency, userSuppliedId] and makes the following REST requests: [contactsSearchOneResult, accountCardSearchNoResults, accountCardCreate]

When a contact exists and has an account: requires minimum parameters [shopperId, currency, userSuppliedId] and makes the following REST requests: [contactsSearchOneResult, accountCardSearchOneResult]

#When a contact doesn't exist: requires minimum parameters [shopperId, currency, userSuppliedId] and makes the following REST requests: [contactsSearchNoResults, contactCreate, accountCardSearchNoResults, accountCardCreate]

Scenario: Create by contactId


@account_retrieval

Scenario: Retrieve by shopperId

Scenario: Retrieve by contactId


@account_details

Scenario: retrieve details by shopperId

Scenario: retrieve details by contactId


@account_transactions

Scenario: Charge by shopperId

Scenario: Charge by contactId

Scenario: Pending charge

Scenario: Capture pending

Scenario: Void pending

Scenario: Simulate charge (nsf: false)

Scenario: Simulate charge (nsf: true)

Scenario: Fund

