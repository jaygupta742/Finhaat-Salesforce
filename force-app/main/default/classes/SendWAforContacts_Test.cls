/* Created By : Suraj 26/07/2024 ,  Description : this test class use for SendWAforContacts  this class
 */ 
@isTest
public class SendWAforContacts_Test {
    @isTest
    Public static void testdata(){
        
        Account acc=New Account();
        acc.WhatsApp_No__c ='7798056741';
        acc.LastName ='Suraj';
        acc.RecordTypeId =    Schema.SObjectType.Account.getRecordTypeInfosByName().get('POS').getRecordTypeId(); 
        insert acc;
        Contact con=New Contact();
        con.LastName ='Suraj';
        con.MobilePhone = '7798056741';
        insert con;
        
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Dummy Content', 
            PathOnClient = 'dummy-content.txt', 
            VersionData = Blob.valueOf('This is dummy content for testing purposes.')
        );
        
        // Insert the dummy content version record
        insert testContentVersion;
        String contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id].ContentDocumentId;
        
        string[] cids=contentDocumentId.split(',');
        Whatsapp_Templates__c wt = new Whatsapp_Templates__c();
        wt.name = 'Wlecome Template For Account';
        wt.Text__c = 'test';
        insert wt;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Send_Wap_Class_Mock());
        SendWAforContacts.tempwap();
        SendWAforContacts.getDocumentSize1(contentDocumentId);
        SendWAforContacts.onsave(con.Id, wt.Text__c, contentDocumentId);
        SendWAforContacts.deletdoc(contentDocumentId);
    }
}