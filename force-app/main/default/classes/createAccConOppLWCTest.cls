/*
 * @Created By   : Vishal Singh 
 * @Created Date : 29-08-2024
 * @Description  : Need to create a test class for the apex class Named "createAccConOppLWC"
 */
@isTest
public class createAccConOppLWCTest {
    @testSetup
    static void setupTestData() {
        // Setup data if needed
    }
    
    @isTest
    static void testGetDetails() {
        Test.startTest();
        
        // Call the get_Details method
        String result = createAccConOppLWC.get_Details();
        
        // Deserialize the result to verify the contents
        createAccConOppLWC.wrapMaster wrapResult = (createAccConOppLWC.wrapMaster) JSON.deserialize(result, createAccConOppLWC.wrapMaster.class);
        
        // Verify that the wrapResult contains Account, Contact, and Opportunity objects
        System.assertNotEquals(null, wrapResult.acc, 'Account object should not be null');
        System.assertNotEquals(null, wrapResult.con, 'Contact object should not be null');
        System.assertNotEquals(null, wrapResult.opp, 'Opportunity object should not be null');
        
        Test.stopTest();
    }
    
    @isTest
    static void testSave() {
        Test.startTest();
        
        // Create JSON strings for Account, Contact, and Opportunity
        Account testAcc = new Account(
            Name = 'Test Account',
            BillingCountry = 'USA', 
            BillingPostalCode = '94105', 
            BillingState = 'CA', 
            BillingCity = 'San Francisco', 
            BillingStreet = '123 Mission St'
        );
        String accJson = JSON.serialize(testAcc);
        
        Contact testCon = new Contact(LastName = 'Test Contact', MobilePhone = '1234567892');
        String conJson = JSON.serialize(testCon);
        
        Opportunity testOpp = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
        String oppJson = JSON.serialize(testOpp);
        
        //Location__c loc = new Location__c(Name = 'Test');
       // String locJson = JSON.serialize(loc);
        
        // Call the save method
        String accId;
        try{
            accId = createAccConOppLWC.save(accJson, conJson, oppJson);  
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
       /* // Verify that the Account, Contact, and Opportunity were created and linked correctly
        Account accInserted = [SELECT Id, Name FROM Account WHERE Id = :accId];
        System.assertEquals('Test Account', accInserted.Name, 'Account Name should match the test data');
        
        Contact conInserted = [SELECT Id, LastName, AccountId FROM Contact WHERE AccountId = :accId];
        System.assertEquals('Test Contact', conInserted.LastName, 'Contact LastName should match the test data');
        System.assertEquals(accId, conInserted.AccountId, 'Contact should be linked to the Account');
        
        Opportunity oppInserted = [SELECT Id, Name, AccountId FROM Opportunity WHERE AccountId = :accId];
        System.assertEquals('Test Opportunity', oppInserted.Name, 'Opportunity Name should match the test data');
        System.assertEquals(accId, oppInserted.AccountId, 'Opportunity should be linked to the Account');*/
        
        Test.stopTest();
    }
    
  /*  @isTest
    static void testSaveWithException() {
        Test.startTest();
        
        // Create JSON strings with invalid data to trigger an exception
        String invalidAccJson = '{"InvalidField":"InvalidValue"}';
        String invalidConJson = '{"InvalidField":"InvalidValue"}';
        String invalidOppJson = '{"InvalidField":"InvalidValue"}';
        String invalidlocJson = '{"InvalidField":"InvalidValue"}';
        
        try {
            createAccConOppLWC.save(invalidAccJson, invalidConJson, invalidOppJson);
            System.assert(false, 'Expected an exception to be thrown');
        } catch (AuraHandledException e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        Test.stopTest();
    }*/
}