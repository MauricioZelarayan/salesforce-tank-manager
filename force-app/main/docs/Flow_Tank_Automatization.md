FLOW NAME: Opportunity - Tank Assignment & Order Automation

PURPOSE: 
Automates the inventory and order management upon Opportunity creation. The Flow prioritizes finding and reserving an available Industrial Tank. If no tank meets the criteria, it automatically initiates a manufacturing order request.

TRIGGER: 
Record-Triggered Flow on Opportunity (After Create).

INPUT REQUIREMENTS:
- Opportunity record being created (must contain fields for Capacity and Maximum Price to define search criteria).

BUSINESS LOGIC:
1. SEARCH (Tank): Queries for the cheapest, available Industrial_Tank__c inventory that meets criteria.
2. DECISION: Checks if an available tank was successfully found.
3. PATH YES (Tank Assignment): 
    a. Updates the Opportunity, linking the found Industrial_Tank__c (Selected_Tank__c).
    b. Reserves the Industrial Tank (updates Status__c to 'Reserved').
4. PATH NO (Order Creation):
    a. SEARCH (Type): Retrieves the best-fit Tank_Type__c template.
    b. CREATES a new Order__c record, linking the Tank Type.
    c. UPDATES the Opportunity, linking the newly created Order record.
    (This ensures the Opportunity is linked to EITHER a Tank OR an Order, never both).

ERROR HANDLING:
- Fault Paths are implemented on all critical data elements (Get Records, Update Records, Create Records).
- System failures (e.g., DML errors) are routed to a standardized logging sequence:
    1. Assignment: Captures the system error details ($Flow.FaultMessage).
    2. Create Record: Persists the failure data to the custom object Error_Log__c.
    3. Action Email: Notifies the administrator immediately.

PERFORMANCE NOTES:
- Uses a single DML operation for the reservation/order path, adhering to best practices.
- Includes fault paths on all critical elements.

TESTING:
- Unit tests cover 100% of functional paths (Tank Found, Order Created, and all associated DML/Get failures).

DEPENDENCIES:
- Industrial_Tank__c.
- Tank_Type__c.
- Order__c.
- Error_Log__c (Custom Logging Object).

VERSION: 1.0
LAST MODIFIED: 2025-11-14
AUTHOR: Mauricio Zelarayán