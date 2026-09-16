/**
 * @description Controller class to handle the insert of tank data. This class must be called from the LWC.
 * @author Mauricio Zelarayán
 * @date 2025-11-14
 */
public with sharing class TankDataController {

    /**
     * @description Performs a single bulk insert of Industrial Tank records.
     * @param tanksToInsertList List of Industrial_Tank__c records to be inserted.
     */
    @AuraEnabled
    public static void insertTanks(List<Industrial_Tank__c> tanksToInsertList) {

        // First check that it is not empty.
        if (tanksToInsertList == null || tanksToInsertList.isEmpty()) {
            System.debug(LoggingLevel.WARN, 'An attempt is being made to insert an empty or null list.');
            throw new AuraHandledException('The Tank List cannot be null or empty');
        }

        // CRUD check: verify the running user has create access on Industrial_Tank__c
        if (!Schema.sObjectType.Industrial_Tank__c.isCreateable()) {
            System.debug(LoggingLevel.WARN, 'User does not have create access on Industrial_Tank__c.');
            throw new AuraHandledException('You do not have permission to create Tank records');
        }

        // If this point is reached, a debug notification is triggered.
        System.debug(LoggingLevel.INFO, 'A bulk insertion of ' + tanksToInsertList.size() + ' tanks is about to be performed');

        try {
            // The DML operation is performed only once, avoiding the use of a loop
            insert tanksToInsertList;
        }
        catch (DmlException e) {
            // Debug for DML error
            System.debug(LoggingLevel.ERROR, 'A DML error has occurred while inserting the tanks: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        catch (Exception e) {
            // Catch-all for any unexpected error (e.g. type coercion issues before DML)
            System.debug(LoggingLevel.ERROR, 'An unexpected error has occurred while inserting the tanks: ' + e.getMessage());
            throw new AuraHandledException('An unexpected error occurred while inserting tanks');
        }
    }
}