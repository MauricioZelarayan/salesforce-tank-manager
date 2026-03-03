/**
 * @description Trigger for Industrial_Tank__c object
 * @author Mauricio Zelarayán
 * @date 2025-11-14
 */
trigger IndustrialTankTrigger on Industrial_Tank__c (after insert) {
    IndustrialTankTriggerHandler.handleAfterInsert(Trigger.newMap.keySet());
}