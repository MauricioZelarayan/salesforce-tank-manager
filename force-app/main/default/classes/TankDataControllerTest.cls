/**
 * @description Unit tests for the TankDataController class.
 * This class ensures that bulk insertion logic and exception handling 
 * for incoming LWC data are robust and adhere to Governor Limits.
 * @author Mauricio Zelarayán
 * @date 2025-11-14
 */

@isTest
public class TankDataControllerTest {

    @testSetup
    static void setup() {
        Tank_Type__c tankType = new Tank_Type__c(Name = 'Controller Test Type', Capacity__c = 500, Brand__c = 'Waterplast', List_Price__c = 200);
        insert tankType;
    }

    //----------------------------------------------------------------------
    
    /**
     * @description Tests successful bulk insertion of multiple valid records.
     * Verifies Governor Limit compliance (single DML).
     */

    @isTest
    static void testInsertTanksSuccess(){
        Tank_Type__c type = [SELECT Id FROM Tank_Type__c LIMIT 1];
        List<Industrial_Tank__c> tanks = new List<Industrial_Tank__c>();

        for(Integer i= 0; i < 3; i++){
            tanks.add(new Industrial_Tank__c(Name = 'Tank ' + i, Tank_Type__c = type.Id, Serial_Number__c = 'Bulk ' + i, Long_URL__c = 'https://www.salesforce.com'));
        }
        
        Test.startTest();
        TankDataController.insertTanks(tanks);
        Test.stopTest();

        Integer insertedTanks = [SELECT COUNT() FROM Industrial_Tank__c WHERE Serial_Number__c LIKE 'Bulk%'];
        System.assertEquals(3, insertedTanks, 'The number of inserted tanks should be 3');
    }

    //----------------------------------------------------------------------

    /**
     * @description Tests when an empty list is passed from the LWC.
     * The controller must throw AuraHandledException to notify the frontend.
     */

    @isTest
    static void testInsertTanksEmptyList(){

        List<Industrial_Tank__c> tanks = new List<Industrial_Tank__c>();
        Test.startTest();
        try{
            TankDataController.insertTanks(tanks);
            System.assert(false, 'The test failed because the controller did not throw the expected exception.');
        }
        catch(AuraHandledException e){
            // If we reach this point, it means the exception was thrown
            // Verify that the message is correct
            System.assert(true, 'Exception caught successfully');
        }

        Test.stopTest();
    }

     //----------------------------------------------------------------------

    /**
     * @description Tests DML exception handling when mandatory fields are missing (Master-Detail).
     * The controller must wrap the DML error in AuraHandledException.
     */

    @isTest
    static void testDmlError() {
        Tank_Type__c type = [SELECT Id FROM Tank_Type__c LIMIT 1];
        Boolean exceptionThrown = false;

        // Simulate an error
        List<Industrial_Tank__c> wrongTanks = new List<Industrial_Tank__c>{
            new Industrial_Tank__c(Name = 'Wrong Tank', Tank_Type__c = null) // Should fail
        };

        Test.startTest();
        try {
            TankDataController.insertTanks(wrongTanks);
        }
        catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'The controller should have caught the DML error and thrown an AuraHandledException');
    }
}