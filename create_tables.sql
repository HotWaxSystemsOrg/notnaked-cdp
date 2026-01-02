-- Universal Data Model (UDM) compliant schema for NotNaked CDP

-- =========================
-- PARTY
-- =========================

-- Stores all parties: individuals or organizations
CREATE TABLE party (
    party_id VARCHAR(30) PRIMARY KEY,
    party_type_id VARCHAR(30) NOT NULL, -- PERSON, ORGANIZATION
    status_id VARCHAR(30), -- ACTIVE, INACTIVE etc.
    from_date DATE NOT NULL,
    thru_date DATE
);

-- Stores individual-specific information
CREATE TABLE person (
    party_id VARCHAR(30) PRIMARY KEY,
    first_name VARCHAR(60) NOT NULL,
    middle_name VARCHAR(60),
    last_name VARCHAR(60) NOT NULL,
    dob DATE,
    gender VARCHAR(1), -- M, F, O
    FOREIGN KEY (party_id) REFERENCES party(party_id)
);

-- Stores organization-specific information
CREATE TABLE org (
    party_id VARCHAR(30) PRIMARY KEY,
    org_name VARCHAR(100),
    org_group_size BIGINT,
    FOREIGN KEY (party_id) REFERENCES party(party_id)
);

-- =========================
-- PARTY IDENTIFICATION
-- =========================

-- Stores external identifiers for a party (Shopify, CRM, etc.)
CREATE TABLE party_identification (
    party_id VARCHAR(30) NOT NULL,
    party_identification_type_id VARCHAR(30) NOT NULL, -- SHOPIFY_CUSTOMER_ID
    id_value VARCHAR(100) NOT NULL,                     -- 7194277478653
    from_date DATE NOT NULL,
    thru_date DATE,
    PRIMARY KEY (party_id, party_identification_type_id, from_date),
    FOREIGN KEY (party_id) REFERENCES party(party_id)
);

-- =========================
-- PARTY ROLE
-- =========================

-- Stores roles assigned to parties
CREATE TABLE party_role (
    party_id VARCHAR(30),
    party_role_type_id VARCHAR(30) NOT NULL, -- CUSTOMER
    from_date DATE NOT NULL,
    thru_date DATE,
    PRIMARY KEY (party_id, party_role_type_id),
    FOREIGN KEY (party_id) REFERENCES party(party_id)
);

-- =========================
-- PARTY SUBSCRIPTION
-- =========================

-- Stores marketing and communication subscriptions for a party
CREATE TABLE party_subscription (
    party_id VARCHAR(30) NOT NULL,
    subscription_type_id VARCHAR(30) NOT NULL,  -- SMS_MARKETING
    subscription_status_id VARCHAR(30) NOT NULL, -- SUBSCRIBED / NOT_SUBSCRIBED
    subscription_source VARCHAR(30) NOT NULL,   -- SHOPIFY
    from_date DATE NOT NULL,
    thru_date DATE,
    PRIMARY KEY (party_id, subscription_type_id, from_date),
    FOREIGN KEY (party_id) REFERENCES party(party_id)
);

-- =========================
-- CONTACT MECHANISMS
-- =========================

-- Stores contact mechanism metadata
CREATE TABLE contact_mech (
    contact_mech_id VARCHAR(30) PRIMARY KEY,
    contact_mech_type_id VARCHAR(30) NOT NULL, -- EMAIL, PHONE, POSTAL_ADDRESS
    email_string VARCHAR(100) -- Used only when type is EMAIL
);

-- Phone-specific contact details
CREATE TABLE phone_number (
    contact_mech_id VARCHAR(30) PRIMARY KEY,
    country_code VARCHAR(5) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    FOREIGN KEY (contact_mech_id) REFERENCES contact_mech(contact_mech_id)
);

-- Address-specific contact details
CREATE TABLE postal_address (
    contact_mech_id VARCHAR(30) PRIMARY KEY,
    address_1 VARCHAR(100) NOT NULL, -- 123, Baker's Street
    address_2 VARCHAR(100),
    city VARCHAR(60) NOT NULL, -- LONDON
    state VARCHAR(60) NOT NULL, -- LONDON
    country VARCHAR(60) NOT NULL, -- ENGLAND
    zip_code VARCHAR(30) NOT NULL, -- 10036
    FOREIGN KEY (contact_mech_id) REFERENCES contact_mech(contact_mech_id)
);

-- Mapping of parties to contact mechanisms with purposes
CREATE TABLE party_contact_mech (
    party_id VARCHAR(30),
    contact_mech_id VARCHAR(30),
    contact_mech_purpose_id VARCHAR(30) NOT NULL, -- PRIMARY_EMAIL, HOME_PHONE, SHIPPING_ADDRESS, BILLING_ADDRESS, etc.
    from_date DATE NOT NULL,
    thru_date DATE,
    PRIMARY KEY (party_id, contact_mech_id),
    FOREIGN KEY (party_id) REFERENCES party(party_id),
    FOREIGN KEY (contact_mech_id) REFERENCES contact_mech(contact_mech_id)
);

-- =========================
-- ENUMERATIONS (LOOKUPS)
-- =========================

-- For enumerations like party role, gender, party type, status, user-login permission, party identification, etc.
CREATE TABLE enumeration (
    enum_id VARCHAR(30) PRIMARY KEY, -- ACTIVE
    enum_type_id VARCHAR(30), -- PARTY_STATUS
    enum_value VARCHAR(30), -- Active
    description VARCHAR(255) -- Status Type for party: Active
);

-- =========================
-- USER AUTHENTICATION & PREFERENCES
-- =========================

-- Stores user login credentials
CREATE TABLE user_login (
    user_login_id VARCHAR(30) PRIMARY KEY,
    party_id VARCHAR(30),
    password VARCHAR(60) NOT NULL,
    is_enabled BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (party_id) REFERENCES party(party_id)
);

-- Permissions applied to users
CREATE TABLE user_login_permission_appl (
    user_login_id VARCHAR(30), -- demo.user@gmail.com
    permission_id VARCHAR(30), -- PRODUCT_VIEW_PERMISSION
    from_date DATE NOT NULL,
    thru_date DATE,
    PRIMARY KEY (user_login_id, permission_id, from_date),
    FOREIGN KEY (user_login_id) REFERENCES user_login(user_login_id)
);

-- Stores user-specific preferences
CREATE TABLE user_preference (
    user_login_id VARCHAR(30), -- demo.user@gmail.com
    userPrefTypeId VARCHAR(30), -- javaScriptEnabled
    userPrefGroupTypeId VARCHAR(30), -- GLOBAL_PREFERENCES
    userPrefValue VARCHAR(100), -- Y
    userPrefDataType VARCHAR(50),
    PRIMARY KEY (user_login_id, userPrefTypeId, userPrefGroupTypeId),
    FOREIGN KEY (user_login_id) REFERENCES user_login(user_login_id)
);

