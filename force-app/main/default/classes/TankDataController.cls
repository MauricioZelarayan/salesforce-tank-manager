
/**
 * @description Controller class to handle and insert of tank data. This class must be called form the LWC.
 * @param tanksToInsertList List of Industrial_Tank__c records to be inserted.
 * @author Mauricio Zelarayán
 * @date 2025-11-14
 */

public with sharing class TankDataController{

    @AuraEnabled
    public static void insertTanks(List<Industrial_Tank__c> tanksToInsertList){

        //First check that it is not empty.
        if( tanksToInsertList == null || tanksToInsertList.isEmpty()){
            System.debug(LoggingLevel.WARN, 'An attempt is being made to insert an empty or null list.'); 
            throw new AuraHandledException('The Tank List cannot be null or empty');
        }
        //If this point is reached, a debug notification is triggered.
        System.debug(LoggingLevel.INFO, 'A bulk insertion of '+ tanksToInsertList.size() +' tanks is about to be performed');
       
        try {
            //The DML operation is performed only once, avoiding the use of a loop
            insert tanksToInsertList;
        } 
        catch (DmlException e) {
            //Debug for DML error
            System.debug(LoggingLevel.ERROR, 'An DML error has occurred while inserting the tanks: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}