/**
 * @description Handler class for IndustrialTankTrigger
 * @author Mauricio Zelarayán
 * @date 2025-11-14
 */
public with sharing class IndustrialTankTriggerHandler {
    
    /**
     * @description Handles after insert logic
     * @param tankIds Set of Id's
     */
    public static void handleAfterInsert(Set<Id> tankIds) {
        
        if (tankIds == null || tankIds.isEmpty()) {
            return; 
        }

        // If there is only one record, call the service to generate the short URL
        if(tankIds.size() == 1) {
            BitlyIntegrationService.generateShortUrl(tankIds);
        }
    }
}