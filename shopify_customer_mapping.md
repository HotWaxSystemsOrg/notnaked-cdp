# Shopify Customer → NotNaked CDP Mapping

## 1. Overview

This document describes the mapping between customer data retrieved from the Shopify Customer API and NotNaked’s Universal Data Model (UDM)–compliant Customer Data Platform (CDP).

The objective of this mapping is to ensure that Shopify customer data is:
- Stored in a normalized and extensible UDM structure
- Able to support multiple contact mechanisms per customer
- Consistent with enterprise-grade customer lifecycle management

---

## 2. High-Level Mapping Strategy

Each Shopify customer is represented in the CDP as a Party with the following characteristics:

- party.partyTypeId = PERSON  
- party_role.partyRoleTypeId = CUSTOMER  

Customer attributes are distributed across UDM entities as follows:

| UDM Entity | Responsibility |
|----------|---------------|
| party | Core identity and lifecycle |
| person | Individual attributes |
| party_identification | External identifiers (Shopify customer ID) |
| contact_mech | Email, phone, and addresses |
| party_contact_mech | Linking customers to contact mechanisms |
| phone_number | Phone-specific data |
| postal_address | Address-specific data |
| party_subscription | Marketing and communication subscriptions |

Multi-valued Shopify fields (such as addresses) are modeled using multiple ContactMech records, in line with UDM principles.

---

## 3. Core Field Mapping (Shopify → CDP)

### Customer-Level Fields

| Shopify Field | Type | CDP Table | CDP Column | Mapping Notes |
|--------------|------|-----------|------------|--------------|
| id | number | party_identification | id_value | party_identification_type_id = SHOPIFY_CUSTOMER_ID |
| first_name | string | person | first_name | Direct mapping |
| last_name | string | person | last_name | Direct mapping |
| email | string | contact_mech | email_string | contactMechTypeId = EMAIL |
| phone | string | phone_number | phone_number | contactMechTypeId = TELECOM_NUMBER |
| created_at | datetime | party | from_date | Converted to DATE |
| state | string | party | status_id | ACTIVE / DISABLED |

---

## 3.1 External Identifier Mapping

Shopify customer identifiers are stored using a dedicated identification model.

| Shopify Field | CDP Table | CDP Column |
|--------------|----------|------------|
| id | party_identification | id_value |

Additional attributes:
- party_identification_type_id = SHOPIFY_CUSTOMER_ID
- from_date = now()

---

## 4. Address Mapping (Multi-Valued Field Handling)

Shopify provides customer addresses as an array of address objects.

### Address Handling Strategy

- Each Shopify address is stored as a separate POSTAL_ADDRESS contact mechanism  
- Addresses are linked to the customer using party_contact_mech  
- Address purpose is derived from Shopify flags  

### Address Field Mapping

| Shopify Address Field | CDP Table | CDP Column |
|----------------------|----------|------------|
| address1 | postal_address | address_1 |
| address2 | postal_address | address_2 |
| city | postal_address | city |
| province | postal_address | state |
| zip | postal_address | zip_code |
| country | postal_address | country |
| phone | phone_number | phone_number |

---

## 4.1 Subscription Mapping (SMS Marketing)

| Shopify Field | CDP Table | CDP Column |
|--------------|----------|------------|
| sms_marketing_consent.state | party_subscription | subscription_status_id |
| sms_marketing_consent.consent_collected_from | party_subscription | subscription_source |

Static mappings:
- subscription_type_id = SMS_MARKETING
- subscription_status_id = SUBSCRIBED / NOT_SUBSCRIBED
- from_date = now()

---

## 5. Data Transformation Rules

- Shopify IDs are not used as primary keys
- External identifiers are stored in party_identification
- Subscription and consent data is stored in party_subscription
- Boolean values are converted to Y/N
- DateTime values are converted to DATE
- Missing optional fields are stored as NULL

---

## 6. Duplicate Handling Strategy

Customers are matched using the following priority:
1. External identifier (SHOPIFY_CUSTOMER_ID)
2. Email address

If a customer exists:
- Update person data
- Upsert contact mechanisms
- Update or expire subscription records
- Expire outdated records using thru_date

---

## 7. Example Transformation

Shopify Input:
{
  "id": 7194277478653,
  "first_name": "Jane",
  "last_name": "Doe",
  "email": "jane@example.com"
}

CDP Result:
- Party (PERSON)
- PartyIdentification (SHOPIFY_CUSTOMER_ID)
- Person (Jane Doe)
- ContactMech (EMAIL)

---

## 8. Summary

This mapping ensures UDM compliance, extensibility, and safe ingestion of Shopify customer data.

---
