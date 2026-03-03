/**
 * @description Test class for Bitly API callout.
 * @author Mauricio Zelarayán
 * @date 2025-11-14
 */
@isTest
public with sharing class BitlyIntegrationTest {

    /**
     * @description Sets up common prerequisite data required for all test methods.
     * Creates a necessary parent record (Tank_Type__c).
     */

    @testSetup
    static void setup(){
        Tank_Type__c tankType = new Tank_Type__c(Name = 'Tank Type 1', Capacity__c = 1000, Brand__c = 'Rotoplas', List_Price__c = 500);
        insert tankType;
    }

    //----------------------------------------------------------------------

    /**
     * @description Tests the single-record insertion scenario.
     * Asserts that the trigger fires the @future callout and successfully 
     * updates the Short_URL__c field with the mocked value.
     */

    @IsTest
    static void testSingleTankInsertion(){
        // Create a tank
        Industrial_Tank__c tank = new Industrial_Tank__c(Name = 'Tank 1', Tank_Type__c = [SELECT Id FROM Tank_Type__c LIMIT 1].Id, Long_URL__c = 'https://www.salesforce.com', Serial_Number__c = 'SIN-001');

        // Call the mock
        Test.setMock(HttpCalloutMock.class, new BitlyCalloutMock());

        // Execute test
        Test.startTest();
        insert tank;
        Test.stopTest();

        // Need to verify that the Short_URL__c field was updated
        Industrial_Tank__c updatedTank = [SELECT Id, Short_URL__c FROM Industrial_Tank__c WHERE Id = : tank.Id];
        System.assertEquals('https://bit.ly/TEST1234', updatedTank.Short_URL__c, 'The Short_URL__c should be updated');
        
    }

    //----------------------------------------------------------------------

    /**
     * @description Tests the bulk insertion.
     * Asserts that the trigger doesn't execute the callout logic when multiple records are inserted (Trigger.new.size() > 1), 
     * ensuring limits are protected.
     */

    @IsTest
    static void testBulkTankInsertion(){
        // Create bulk tanks
        List<Industrial_Tank__c> tanks = new List<Industrial_Tank__c>();
        Tank_Type__c type = [SELECT Id FROM Tank_Type__c LIMIT 1];

        // loop creation
        for(Integer i = 0; i < 10; i++){
            tanks.add(new Industrial_Tank__c(Name = 'Tank ' + i, Tank_Type__c = type.Id, Serial_Number__c = 'Bulk ' + i, Long_URL__c = 'https://www.salesforce.com'));
        }

        // Call the mock
        Test.setMock(HttpCalloutMock.class, new BitlyCalloutMock());

        // Execute test
        Test.startTest();
        insert tanks;
        Test.stopTest();

        // Need to verify that the Short_URL__c field was not updated
        Industrial_Tank__c updatedTank = [SELECT Short_URL__c FROM Industrial_Tank__c WHERE Serial_Number__c = 'Bulk 0'];
        System.assertEquals(null, updatedTank.Short_URL__c, 'The Short_URL__c field shouldnt be updated');
    }
}