# Data Access Logic — NotNaked CDP

This document describes the pseudo-code for accessing and manipulating customer data
within the NotNaked Customer Data Platform (CDP), implemented using UDM principles
and designed for execution in the Moqui Framework.

---

## Service: createCustomer

**Purpose:**  
Create a new customer with basic information, contact mechanisms, address, login credentials,
external identifiers, and subscription data.

### Parameters
- firstName  
- lastName  
- email  
- phone  
- dob  
- gender  
- addressMap  
- phoneMap  
- password  
- shopifyCustomerId  
- smsMarketingState  
- smsConsentSource  

### Logic
1. Validate required fields (firstName, lastName, email).
2. Generate a new partyId using getNextSeqId("Party").
3. Create Party record (PERSON, PARTY_ENABLED).
4. Create PartyIdentification record (SHOPIFY_CUSTOMER_ID).
5. Create Person record.
6. Assign CUSTOMER role using PartyRole.
7. Create EMAIL ContactMech and link via PartyContactMech.
8. If phone is present:
   - Create TELECOM_NUMBER ContactMech
   - Create PhoneNumber record
   - Link via PartyContactMech
9. Create POSTAL_ADDRESS ContactMech using addressMap.
10. Link address via PartyContactMech.
11. Create PartySubscription record for SMS marketing consent.
12. Create UserLogin record.
13. Return success with created partyId.

---

## Service: getCustomerById

**Purpose:**  
Retrieve full customer information using partyId.

### Parameters
- partyId

### Logic
1. Fetch Party by partyId.
2. If not found, return error "Customer Not Found".
3. Fetch Person record.
4. Fetch PartyIdentification records.
5. Fetch PartyContactMech records.
6. Fetch PartySubscription records.
7. Aggregate person, identifiers, contact mechanisms, and subscriptions.
8. Return success.

---

## Service: getCustomerList

**Purpose:**  
Retrieve a list of all customers with full details.

### Parameters
- None

### Logic
1. Fetch all Parties with CUSTOMER role.
2. For each party:
   - Fetch Person
   - Fetch PartyIdentification
   - Fetch ContactMech records
   - Fetch PartySubscription records
3. Aggregate and return list.

---

## Service: updateCustomer

**Purpose:**  
Update existing customer information.

### Parameters
- partyId  
- firstName?  
- lastName?  
- dob?  
- gender?  
- email?  
- phoneMap?  
- addressMap?  
- smsMarketingState?  
- smsConsentSource?  

### Logic
1. Validate party exists.
2. Update Person fields if present.
3. Update or recreate EMAIL ContactMech if email changes.
4. Update or recreate TELECOM_NUMBER ContactMech if phone changes.
5. Update or recreate POSTAL_ADDRESS ContactMech if address changes.
6. If SMS subscription data changes:
   - Expire existing PartySubscription
   - Create new PartySubscription
7. Return success.

---

## Service: deleteCustomer

**Purpose:**  
Soft-delete a customer while preserving history.

### Parameters
- partyId

### Logic
1. Validate party exists.
2. Set party.statusId = PARTY_DISABLED.
3. Set thru_date = now() on:
   - Party
   - PartyRole
   - PartyContactMech
   - PartySubscription
4. Do not physically delete records.
5. Return success message.

---

## Notes

- External identifiers are managed via party_identification.
- Marketing consent is managed via party_subscription.
- All delete operations are soft deletes.
- Contact mechanisms support historical tracking.
