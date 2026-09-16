FLOW NAME: Opportunity - Account Stats Updater

PURPOSE: 
Automates the updating of customer purchase statistics and preferred brand upon successful sale closure (Closed Won). This ensures the Account data is maintained automatically.

TRIGGER: 
Record-Triggered Flow on Opportunity (After Update, when StageName equals 'Closed Won').

INPUT REQUIREMENTS:
- Opportunity record being updated.
- Valid AccountId linked to the Opportunity.
- Valid reference in Selected_Tank__c field.

BUSINESS LOGIC:
1. Executes only when the Opportunity StageName changes to 'Closed Won'.
2. Retrieves the assigned Industrial_Tank__c record (via Selected_Tank__c lookup).
3. Traverses the relationship to find the Brand from the Tank_Type__c record.
4. Updates the related Account record by:
    a. Incrementing the Tanks Purchased counter (BLANKVALUE safe arithmetic).
    b. Setting the Preferred Brand (Preferred_Brand__c) to the brand of the tank sold.
5. If no tank is found (no tank was assigned, e.g., only an Order exists), the Flow ends cleanly.

ERROR HANDLING:
- Fault Paths are implemented on all Get Records and Update Records elements.
- System failures (DML errors, Locking) are routed to a standardized logging sequence:
    1. Assignment: Captures system error details ($Flow.FaultMessage).
    2. Create Record: Persists the failure data to the custom object Error_Log__c.
    3. Action Email: Notifies the administrator immediately.

PERFORMANCE NOTES:
- Utilizes efficient single DML operations (Update Account) for the core logic.
- Avoids all loops and unnecessary SOQL queries.
- Includes fault paths on all critical elements.

TESTING:
- Unit tests cover 100% of functional paths (Success path, No Tank path, and Update failure path).

DEPENDENCIES:
- Account Object (Requires custom fields for Count and Brand).
- Industrial_Tank__c Object.
- Tank_Type__c Object.
- Error_Log__c (Custom Logging Object).

VERSION: 1.0
LAST MODIFIED: 2025-11-14
AUTHOR: Mauricio Zelarayán