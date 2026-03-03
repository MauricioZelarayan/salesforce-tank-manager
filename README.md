# Salesforce Tank Manager: Automated Sales & Inventory Management System
**Developer:** Mauricio Zelarayán

## Project Overview
Salesforce Tank Manager is a comprehensive Salesforce solution designed for an industrial tank supplier. It optimizes the entire business lifecycle, from high-volume inventory intake to intelligent sales opportunity conversion.

## Key Features & Implementation

### 1. Inventory Management (LWC)
* **Bulk Tank Loader:** A Lightning Web Component that processes CSV files on the client-side using the PapaParse library.
* **3-Step Wizard:** A seamless interface for defining tank types, uploading files, and confirming data before database insertion.
* **DML Optimization:** Performs a single bulk insert operation to respect Salesforce Governor Limits and ensure efficient data processing.

### 2. Sales Automation (Flows)
* **Intelligent Reservation:** A Record-Triggered Flow on the Opportunity object automatically searches for the best available tank matching the client's capacity and price requirements.
* **Order Fallback:** If no stock is available, the system automatically generates a Manufacturing Order record.
* **Data Integrity:** Ensures an Opportunity is linked to either a Tank or an Order, effectively preventing data duplication or conflict.

### 3. Apex Architecture & Security
* **Trigger-Handler Pattern:** Clean and scalable code achieved by separating logic into dedicated Handler classes.
* **Bitly Integration:** An asynchronous service using @future (callout=true) that automatically generates shortened tracking URLs for each industrial tank.
* **Robust Security:** Implementation of Permission Sets based on the principle of least privilege for Sales and Maintenance users.

### 4. Resilience (Error Handling)
* **Fault Paths:** All critical data elements include fault routes to capture system error messages and prevent silent failures.
* **Custom Logging:** Errors are persisted in a custom object (Error_Log__c), and administrators are automatically notified via email for immediate troubleshooting.

## Tech Stack
* **Salesforce:** LWC, Apex (Triggers, Services), Flows, SOQL, DML

## License
Copyright (c) 2026 Mauricio Zelarayán. This project is licensed under the MIT License - see the LICENSE file for details.