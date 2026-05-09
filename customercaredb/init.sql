-- ============================================================
-- CUSTOMER CARE SUPPORT DATABASE
-- ============================================================

-- ============================================================
-- ENUMS
-- ============================================================

CREATE TYPE ticket_priority AS ENUM (
    'low',
    'medium',
    'high',
    'critical'
);

CREATE TYPE channel AS ENUM (
    'email',
    'phone',
    'chat',
    'in_store',
    'social_media'
);

-- ============================================================
-- PRODUCT CATALOG
-- ============================================================

CREATE TABLE product_categories (
    product_id         SERIAL PRIMARY KEY,
    sku                VARCHAR(50) UNIQUE NOT NULL,
    category           VARCHAR(100) NOT NULL,
    brand              VARCHAR(100) NOT NULL,
    name               VARCHAR(255) NOT NULL,
    model_number       VARCHAR(100),
    warranty_months    INT DEFAULT 12,
    price              NUMERIC(10,2),
    created_at         TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 50 PRODUCTS
-- ============================================================

INSERT INTO product_categories
(sku, category, brand, name, model_number, warranty_months, price)
VALUES

-- TVs
('TV-SAM-S90D','Television','Samsung','Samsung S90D OLED 65"','QN65S90D',24,189999.00),
('TV-LG-G4','Television','LG','LG G4 OLED evo 77"','OLED77G4',24,329999.00),
('TV-SNY-X90L','Television','Sony','Sony Bravia X90L 75"','XR75X90L',24,249999.00),
('TV-HIS-U7K','Television','Hisense','Hisense U7K Mini LED 65"','65U7K',24,94999.00),
('TV-TCL-C845','Television','TCL','TCL C845 QLED 75"','75C845',24,129999.00),

-- Laptops
('LAP-ASU-ZG14','Laptop','ASUS','ASUS ROG Zephyrus G14','GA403UV',12,199999.00),
('LAP-APL-MBA15','Laptop','Apple','MacBook Air 15 M3','MBA15M3',12,164999.00),
('LAP-DEL-ALIEN','Laptop','Dell','Alienware m16 R2','AWM16R2',12,249999.00),
('LAP-HP-SPECTRE','Laptop','HP','HP Spectre x360 14','14-EF2033TU',12,154999.00),
('LAP-LEN-YOGA9','Laptop','Lenovo','Lenovo Yoga 9i','14IRP8',12,169999.00),

-- Smartphones
('PHN-APL-IP15','Smartphone','Apple','iPhone 15 128GB','A3090',12,79900.00),
('PHN-APL-IP15PM','Smartphone','Apple','iPhone 15 Pro Max','A3108',12,159900.00),
('PHN-SAM-S24','Smartphone','Samsung','Samsung Galaxy S24','SM-S921B',12,74999.00),
('PHN-SAM-ZF6','Smartphone','Samsung','Samsung Galaxy Z Fold 6','SM-F956B',12,179999.00),
('PHN-GOO-PIX8','Smartphone','Google','Google Pixel 8','GKWS6',12,75999.00),

-- Audio
('AUD-SON-ULT','Audio','Sony','Sony ULT Wear','WH-ULT900N',12,18999.00),
('AUD-BOSE-ULTRA','Audio','Bose','Bose QuietComfort Ultra','QC-ULTRA',12,39999.00),
('AUD-APP-AIRPODS','Audio','Apple','AirPods Pro Gen 2','MTJV3HN/A',12,24900.00),
('AUD-JBL-BOOMBOX3','Audio','JBL','JBL Boombox 3','BOOMBOX3',12,44999.00),
('AUD-SEN-M4','Audio','Sennheiser','Momentum 4 Wireless','M4AEBT',12,34999.00),

-- Tablets
('TAB-APL-IPADMINI','Tablet','Apple','iPad Mini 6','MK7R3HN/A',12,49900.00),
('TAB-SAM-S9U','Tablet','Samsung','Galaxy Tab S9 Ultra','SM-X910',12,119999.00),
('TAB-XIA-PAD6','Tablet','Xiaomi','Xiaomi Pad 6','23043RP34G',12,28999.00),
('TAB-ONE-PAD2','Tablet','OnePlus','OnePlus Pad 2','OPD2404',12,39999.00),

-- Wearables
('WCH-APL-ULTRA2','Wearable','Apple','Apple Watch Ultra 2','MREJ3HN/A',12,89900.00),
('WCH-SAM-GW7','Wearable','Samsung','Galaxy Watch 7','SM-L310',12,32999.00),
('WCH-GRM-VENU3','Wearable','Garmin','Garmin Venu 3','010-02784',24,52999.00),
('WCH-FIT-SENSE2','Wearable','Fitbit','Fitbit Sense 2','FB521',12,24999.00),

-- Cameras
('CAM-CAN-R50','Camera','Canon','Canon EOS R50','R50',24,78999.00),
('CAM-NIK-ZF','Camera','Nikon','Nikon Zf Mirrorless','ZF',24,199999.00),
('CAM-FUJ-XT5','Camera','Fujifilm','Fujifilm X-T5','XT5',24,169999.00),
('CAM-GOP-H12','Camera','GoPro','GoPro Hero 12 Black','CHDHX-121',12,45999.00),

-- Storage
('SSD-SAM-990P','Storage','Samsung','Samsung 990 Pro 2TB','MZ-V9P2T0BW',60,22999.00),
('SSD-CRU-X10','Storage','Crucial','Crucial X10 Pro 4TB','CT4000X10PRO',60,32999.00),
('SSD-WD-P40','Storage','WD','WD Black P40','WDBAWY0020BBK',36,17999.00),

-- Networking
('RTR-ASU-BE98','Networking','ASUS','ASUS ROG Rapture BE98','GT-BE98',24,69999.00),
('RTR-NET-RAXE500','Networking','Netgear','Netgear RAXE500','RAXE500',24,55999.00),
('RTR-TP-XE75','Networking','TP-Link','TP-Link Deco XE75','XE75',24,32999.00),

-- Gaming
('CON-SON-PS5PRO','Gaming','Sony','PlayStation 5 Pro','CFI-7021',12,74990.00),
('CON-NIN-SWITCH','Gaming','Nintendo','Nintendo Switch OLED','HEG-001',12,32999.00),
('CON-VAL-STEAM','Gaming','Valve','Steam Deck OLED','OLED512',12,58999.00),

-- Monitors
('MON-SAM-ODYSSEY','Monitor','Samsung','Samsung Odyssey G9 OLED','LS49CG954',24,169999.00),
('MON-ASU-PG32','Monitor','ASUS','ASUS ROG Swift PG32UCDM','PG32UCDM',24,149999.00),
('MON-DEL-U4025','Monitor','Dell','Dell UltraSharp U4025QW','U4025QW',24,199999.00),

-- Smart Home
('HOME-GOO-NEST','Smart Home','Google','Google Nest Hub Max','GA00639',12,22999.00),
('HOME-APP-HOMEPOD','Smart Home','Apple','Apple HomePod Gen 2','MQJ83HN/A',12,32900.00),
('HOME-AMA-ECHO15','Smart Home','Amazon','Amazon Echo Show 15','H6R7A5',12,28999.00),

-- Accessories
('ACC-LOG-MX3S','Accessory','Logitech','Logitech MX Master 3S','910-006560',12,10999.00),
('ACC-RAZ-VIPER3','Accessory','Razer','Razer Viper V3 Pro','RZ01-0512',12,15999.00),
('ACC-ANK-737','Accessory','Anker','Anker 737 Power Bank','A1289',18,13999.00),
('ACC-BEL-TB4','Accessory','Belkin','Belkin Thunderbolt 4 Dock','INC006',24,34999.00);

-- ============================================================
-- TICKET CATEGORIES
-- ============================================================

CREATE TABLE ticket_categories (
    category_id        SERIAL PRIMARY KEY,
    category_code      VARCHAR(50) UNIQUE NOT NULL,
    category_name      VARCHAR(100) NOT NULL,
    sla_hours          INT DEFAULT 24,
    is_active          BOOLEAN DEFAULT TRUE
);

INSERT INTO ticket_categories
(category_code, category_name, sla_hours)
VALUES
('product_defect','Product Defect',48),
('warranty_claim','Warranty Claim',72),
('installation_support','Installation Support',24),
('software_issue','Software Issue',24),
('shipping_damage','Shipping Damage',12),
('returns_refunds','Returns & Refunds',48),
('billing','Billing',24),
('general_inquiry','General Inquiry',12);

-- ============================================================
-- TICKET STATUSES
-- ============================================================

CREATE TABLE ticket_statuses (
    status_id          SERIAL PRIMARY KEY,
    status_code        VARCHAR(50) UNIQUE NOT NULL,
    status_name        VARCHAR(50) NOT NULL
);

INSERT INTO ticket_statuses
(status_code, status_name)
VALUES
('open','Open'),
('in_progress','In Progress'),
('resolved','Resolved'),
('closed','Closed'),
('escalated','Escalated');

-- ============================================================
-- CUSTOMERS
-- ============================================================

CREATE TABLE customers (
    customer_id        SERIAL PRIMARY KEY,
    full_name          VARCHAR(255) NOT NULL,
    email              VARCHAR(255) UNIQUE NOT NULL,
    phone              VARCHAR(20),
    city               VARCHAR(100),
    created_at         TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO customers
(full_name,email,phone,city)
VALUES
('Arjun Sharma','arjun@email.com','+91-9876543210','Hyderabad'),
('Priya Nair','priya@email.com','+91-9823456789','Bangalore'),
('Rahul Mehta','rahul@email.com','+91-9712345678','Mumbai'),
('Sneha Reddy','sneha@email.com','+91-9645321870','Hyderabad'),
('Vikram Patel','vikram@email.com','+91-9534218760','Ahmedabad'),
('Anjali Iyer','anjali@email.com','+91-9421987650','Chennai'),
('Kiran Rao','kiran@email.com','+91-9398765430','Pune'),
('Deepak Gupta','deepak@email.com','+91-9287654320','Delhi'),
('Meena Krishnan','meena@email.com','+91-9176543210','Kochi'),
('Suresh Babu','suresh@email.com','+91-9065432100','Vizag');

-- ============================================================
-- AGENTS WITH ALL LEVELS
-- ============================================================

CREATE TABLE agents (
    agent_id           SERIAL PRIMARY KEY,
    full_name          VARCHAR(255) NOT NULL,
    email              VARCHAR(255) UNIQUE NOT NULL,
    department         VARCHAR(100),
    employee_code      VARCHAR(20) UNIQUE,
    support_level      VARCHAR(50),
    specialization     VARCHAR(100),
    shift_timing       VARCHAR(50),
    location           VARCHAR(100),
    is_active          BOOLEAN DEFAULT TRUE,
    created_at         TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO agents
(full_name,email,department,employee_code,support_level,specialization,shift_timing,location)
VALUES

('Ravi Kumar','ravi.kumar@support.com','Customer Care','EMP-L1-1001','L1','General Electronics','Morning','Hyderabad'),
('Lakshmi Devi','lakshmi.devi@support.com','Customer Care','EMP-L1-1002','L1','Mobile Devices','Morning','Bangalore'),
('Naveen Raj','naveen.raj@support.com','Technical Support','EMP-L2-2001','L2','Laptops','Evening','Hyderabad'),
('Pooja Menon','pooja.menon@support.com','Technical Support','EMP-L2-2002','L2','Networking','Evening','Bangalore'),
('Aditya Singh','aditya.singh@support.com','Advanced Support','EMP-L3-3001','L3','Hardware Diagnostics','Morning','Mumbai'),
('Sanjay Verma','sanjay.verma@support.com','Escalations','EMP-ESC-4001','Escalation','Critical Cases','Night','Delhi'),
('Priyanka Nair','priyanka.nair@support.com','Billing','EMP-BIL-5001','Finance','Refunds','Morning','Kochi'),
('Harika Rao','harika.rao@support.com','Returns Team','EMP-RET-6001','Returns','Replacement Logistics','Evening','Hyderabad'),
('Meera Krishnan','meera.krishnan@support.com','Quality Assurance','EMP-QA-7001','QA','Call Audits','Morning','Chennai'),
('Anil Reddy','anil.reddy@support.com','Operations','EMP-SUP-8001','Supervisor','Operations','Morning','Hyderabad'),
('Ramesh Narayanan','ramesh.n@support.com','Management','EMP-MGR-9001','Manager','Customer Care','Morning','Bangalore'),
('Rajesh Khanna','rajesh.khanna@support.com','Executive Support','EMP-DIR-10001','Director','Customer Experience','Morning','Mumbai');

-- ============================================================
-- SUPPORT TICKETS
-- ============================================================

CREATE TABLE tickets (
    ticket_id          SERIAL PRIMARY KEY,
    ticket_ref         VARCHAR(20) UNIQUE NOT NULL,

    customer_id        INT REFERENCES customers(customer_id),
    product_id         INT REFERENCES product_categories(product_id),
    agent_id           INT REFERENCES agents(agent_id),

    category_id        INT REFERENCES ticket_categories(category_id),
    status_id          INT REFERENCES ticket_statuses(status_id),

    channel            channel NOT NULL DEFAULT 'email',
    priority           ticket_priority NOT NULL DEFAULT 'medium',

    subject            VARCHAR(500) NOT NULL,
    description        TEXT NOT NULL,

    created_at         TIMESTAMPTZ DEFAULT NOW(),
    updated_at         TIMESTAMPTZ DEFAULT NOW(),
    resolved_at        TIMESTAMPTZ
);

-- ============================================================
-- SAMPLE TICKETS ALL STAGES
-- ============================================================

INSERT INTO tickets
(ticket_ref,customer_id,product_id,agent_id,category_id,status_id,channel,priority,subject,description,created_at,resolved_at)
VALUES

('TKT-2024-00001',1,1,1,1,3,'email','high',
'Dead pixels on Samsung OLED TV',
'Customer reported dead pixels after 2 weeks usage.',
NOW() - INTERVAL '30 days',
NOW() - INTERVAL '25 days'),

('TKT-2024-00002',2,7,3,4,3,'chat','medium',
'MacBook battery drain issue',
'Battery drains rapidly after latest update.',
NOW() - INTERVAL '20 days',
NOW() - INTERVAL '15 days'),

('TKT-2024-00003',3,13,2,1,1,'phone','high',
'Samsung Galaxy overheating',
'Phone overheats during charging.',
NOW() - INTERVAL '2 days',
NULL),

('TKT-2024-00004',4,18,4,4,2,'chat','medium',
'AirPods ANC not working',
'Noise cancellation weaker after firmware update.',
NOW() - INTERVAL '5 days',
NULL),

('TKT-2024-00005',5,39,6,5,5,'email','critical',
'PS5 Pro damaged during shipping',
'Console panel cracked upon delivery.',
NOW() - INTERVAL '6 days',
NULL),

('TKT-2024-00006',6,24,1,3,4,'phone','low',
'Help setting up OnePlus Pad',
'Customer needs installation support.',
NOW() - INTERVAL '12 days',
NOW() - INTERVAL '11 days'),

('TKT-2024-00007',7,35,4,2,5,'email','critical',
'ASUS router hardware failure',
'Router stopped powering on.',
NOW() - INTERVAL '3 days',
NULL),

('TKT-2024-00008',8,46,7,6,2,'chat','medium',
'Refund delay for Logitech mouse',
'Refund not received after return.',
NOW() - INTERVAL '4 days',
NULL),

('TKT-2024-00009',9,33,3,4,3,'phone','medium',
'SSD not detected in Windows',
'Drive intermittently disconnects.',
NOW() - INTERVAL '14 days',
NOW() - INTERVAL '10 days'),

('TKT-2024-00010',10,41,5,1,1,'social_media','high',
'Monitor screen flickering',
'Monitor flickers at 240Hz.',
NOW() - INTERVAL '1 day',
NULL);

-- ============================================================
-- RESOLUTIONS
-- ============================================================

CREATE TABLE resolutions (
    resolution_id      SERIAL PRIMARY KEY,
    ticket_id          INT UNIQUE REFERENCES tickets(ticket_id),
    resolved_by        INT REFERENCES agents(agent_id),

    resolution_summary TEXT NOT NULL,
    root_cause         TEXT,
    action_taken       TEXT NOT NULL,

    refund_issued      BOOLEAN DEFAULT FALSE,
    refund_amount      NUMERIC(10,2),

    replacement_issued BOOLEAN DEFAULT FALSE,

    customer_rating    SMALLINT
        CHECK (customer_rating BETWEEN 1 AND 5),

    resolved_at        TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO resolutions
(ticket_id,resolved_by,resolution_summary,root_cause,action_taken,refund_issued,refund_amount,replacement_issued,customer_rating,resolved_at)
VALUES

(1,1,
'TV panel replaced successfully.',
'Manufacturing panel defect.',
'Technician replaced panel under warranty.',
FALSE,NULL,TRUE,5,
NOW() - INTERVAL '25 days'),

(2,3,
'Battery issue resolved.',
'Background process bug after update.',
'Installed firmware patch and optimized battery settings.',
FALSE,NULL,FALSE,4,
NOW() - INTERVAL '15 days'),

(6,1,
'Tablet setup completed.',
'Customer required onboarding support.',
'Remote setup completed via video call.',
FALSE,NULL,FALSE,5,
NOW() - INTERVAL '11 days'),

(9,3,
'SSD firmware updated successfully.',
'Firmware compatibility issue.',
'Updated SSD firmware and chipset drivers.',
FALSE,NULL,FALSE,4,
NOW() - INTERVAL '10 days');

-- ============================================================
-- TICKET COMMENTS
-- ============================================================

CREATE TABLE ticket_comments (
    comment_id         SERIAL PRIMARY KEY,
    ticket_id          INT REFERENCES tickets(ticket_id),
    agent_id           INT REFERENCES agents(agent_id),
    is_internal        BOOLEAN DEFAULT FALSE,
    body               TEXT NOT NULL,
    created_at         TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO ticket_comments
(ticket_id,agent_id,is_internal,body,created_at)
VALUES

(1,1,TRUE,'Dead pixel issue verified remotely.',NOW() - INTERVAL '29 days'),
(2,3,FALSE,'Please install latest macOS patch.',NOW() - INTERVAL '18 days'),
(3,2,TRUE,'Thermal readings exceed expected values.',NOW() - INTERVAL '1 day'),
(4,4,FALSE,'Firmware rollback currently under testing.',NOW() - INTERVAL '2 days'),
(5,6,TRUE,'Awaiting logistics damage inspection report.',NOW() - INTERVAL '5 days'),
(7,5,TRUE,'Escalated to ASUS enterprise warranty team.',NOW() - INTERVAL '2 days'),
(8,7,FALSE,'Refund processing initiated.',NOW() - INTERVAL '3 days');

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_products_category
ON product_categories(category);

CREATE INDEX idx_products_brand
ON product_categories(brand);

CREATE INDEX idx_tickets_status
ON tickets(status_id);

CREATE INDEX idx_tickets_category
ON tickets(category_id);

CREATE INDEX idx_tickets_customer
ON tickets(customer_id);

CREATE INDEX idx_agents_level
ON agents(support_level);

-- ============================================================
-- VIEWS
-- ============================================================

CREATE VIEW v_product_catalog AS
SELECT
    sku,
    category,
    brand,
    name,
    model_number,
    warranty_months,
    price
FROM product_categories;

CREATE VIEW v_ticket_overview AS
SELECT
    t.ticket_ref,
    c.full_name AS customer_name,
    p.name AS product_name,
    p.brand,
    tc.category_name,
    ts.status_name,
    t.priority,
    a.full_name AS assigned_agent,
    t.subject,
    t.created_at,
    t.resolved_at
FROM tickets t
JOIN customers c
    ON t.customer_id = c.customer_id
JOIN product_categories p
    ON t.product_id = p.product_id
JOIN ticket_categories tc
    ON t.category_id = tc.category_id
JOIN ticket_statuses ts
    ON t.status_id = ts.status_id
LEFT JOIN agents a
    ON t.agent_id = a.agent_id;

CREATE VIEW v_resolution_summary AS
SELECT
    t.ticket_ref,
    r.resolution_summary,
    r.root_cause,
    r.action_taken,
    r.customer_rating,
    r.refund_issued,
    r.refund_amount,
    r.replacement_issued
FROM resolutions r
JOIN tickets t
    ON r.ticket_id = t.ticket_id;

CREATE VIEW v_agent_performance AS
SELECT
    a.full_name,
    a.support_level,
    a.department,
    COUNT(t.ticket_id) AS total_tickets,
    COUNT(r.resolution_id) AS resolved_tickets,
    ROUND(AVG(r.customer_rating),2) AS avg_rating
FROM agents a
LEFT JOIN tickets t
    ON a.agent_id = t.agent_id
LEFT JOIN resolutions r
    ON t.ticket_id = r.ticket_id
GROUP BY
    a.agent_id,
    a.full_name,
    a.support_level,
    a.department;

-- ============================================================
-- DOCKER INIT USAGE
-- ============================================================

-- Save this file as:
--
-- ./db/init/01_customer_care.sql
--
-- docker-compose.yml:
--
-- version: '3.9'
--
-- services:
--   postgres:
--     image: postgres:16
--     container_name: customer-care-db
--
--     environment:
--       POSTGRES_DB: customer_care
--       POSTGRES_USER: postgres
--       POSTGRES_PASSWORD: postgres
--
--     ports:
--       - "5432:5432"
--
--     volumes:
--       - ./db/init:/docker-entrypoint-initdb.d
--
-- ============================================================
-- START DATABASE
-- ============================================================
--
-- docker compose up -d
--
-- PostgreSQL automatically executes this SQL file
-- during container startup.
--
-- ============================================================