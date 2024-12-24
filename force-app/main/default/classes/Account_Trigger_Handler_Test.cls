@isTest
public class Account_Trigger_Handler_Test {
    
    @testSetup
    static void setupTestData() {
        // Query the test record type, assuming it exists in the org
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Partner' LIMIT 1];

        // Create a test user
        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser10@example.com.test',
            Alias = 'test',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert u;
        
        // Create test accounts with different stages
        List<Account> accList = new List<Account>{
            new Account(
                Name = 'Doe',
                WhatsApp_No__c = '1234567890',
                Stage__c = 'Lead',
                OwnerId = u.Id,
                RecordTypeId = rt.Id
            ),
            new Account(
                Name = 'Smith',
                WhatsApp_No__c = '0987654321',
                Stage__c = 'Lead',
                OwnerId = u.Id,
                RecordTypeId = rt.Id
            )
        };
        insert accList;
        
    }
    
    @isTest
    static void testSendWhatsMessageWhenAccountStagechange() {
        List<Account> accList = [SELECT Id, FirstName, LastName, WhatsApp_No__c, Stage__c, RecordTypeId, OwnerId 
                                FROM Account];
        For(Account ac: accList){
            If(ac.Stage__c != Null){
                ac.Stage__c = 'Payment';
            }
        }
        Update accList;
        String accString = JSON.serialize(accList);
        
        
        Test.startTest();
        Account_Trigger_Handler.sendWhatsMessageWhenAccountStagechange(accString);
        Test.stopTest();
        
    }

    @isTest
    static void testExceptionHandling() {
        
        String invalidJson = 'invalid_json_string';
        Test.startTest();
        Account_Trigger_Handler.sendWhatsMessageWhenAccountStagechange(invalidJson);
        Test.stopTest();
    }
}