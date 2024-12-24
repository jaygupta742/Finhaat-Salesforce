@isTest public class CallDetails_TriggerTest {
    @TestSetup public static void createDate(){
        Account accountRecord = new Account();
        accountRecord.Name = 'Test Account';
        accountRecord.Account_Created_By_Callyzer__c = true;
        accountRecord.Phone = '6325698565';
        
        Insert accountRecord;
        
        Contact contactRecord = new Contact();
        contactRecord.LastName = 'Test Contact';
        contactRecord.AccountId = accountRecord.Id;
        contactRecord.Phone = '6325698565';
        contactRecord.MobilePhone = '6325698565';
        
        Insert contactRecord;
    }
    
    @isTest public static void testTrigger(){
        Call_Detail__c callDetails = new Call_Detail__c();
        
        Account accountRecord = [SELECT Id From Account LIMIT 1];
        Contact contactRecord = [SELECT Id From Contact LIMIT 1];
        
        callDetails.Call_From__c = '7041733029';
        callDetails.Call_ID__c = '7041733029';
        callDetails.Call_To__c = '7041733029';
        callDetails.Call_Type__c = 'Outgoing';
        callDetails.Status__c = 'Success';
        callDetails.Account__c = accountRecord.Id;
        callDetails.Contact__c = contactRecord.Id;
        callDetails.Recording_File__c = 'https://google.com';
        
        Test.setMock(HttpCalloutMock.class, new CalloutMockForTestClass());
        
        insert callDetails;
    }
    
    
}