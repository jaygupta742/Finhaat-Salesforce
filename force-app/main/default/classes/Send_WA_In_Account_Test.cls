//Created By : Abdul Aziz , Created Date : 23/02/2024 , Description :
@isTest
private class Send_WA_In_Account_Test{
    @isTest
    static void testSendWap(){
        Account testAccount = new Account();
        testAccount.Name = 'Test Account1111';
        testAccount.WhatsApp_No__c = '1111111111';
        testAccount.Phone = '1254587458';
        insert testAccount;
        
        Account testAccount2 = new Account();
        testAccount2.LastName = 'Test Account2222';
        testAccount2.PersonMobilePhone = '2222222222';
        Id recordTypeId = [SELECT Id
                           FROM RecordType
                           WHERE SObjectType = 'Account' AND Name = 'POS' AND IsPersonType = true
                           LIMIT 1].Id;
        testAccount2.RecordTypeId = recordTypeId;
        insert testAccount2;
        
        Ticket__c tc = new Ticket__c();
        tc.Account__c = testAccount2.Id;
        insert tc;
        
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
        Send_WA_In_Account.tempwap(tc.id);
        Send_WA_In_Account.getwhats(testAccount2.id);
        try{
            Send_Wap_Class.send_wap(testAccount2.PersonMobilePhone, 'Test SMS', 'Account', testAccount2.Id, cids);
        } catch ( Exception e ){
        }
        try{
            Send_WA_In_Account.onsave(String.valueof(testAccount2.id), 'text_body', contentDocumentId);
        } catch ( Exception e ){
        }
        try{
            Send_WA_In_Account.onsave(String.valueof(tc.id), 'text_body', contentDocumentId);
        } catch ( Exception e ){
        }
        Send_WA_In_Account.getDocumentSize1(contentDocumentId);
        
        /*  try{
Send_Wap_Class.send_wap(testAccount2.PersonMobilePhone, 'Test SMS', 'Account', tc.Id);
}
catch(Exception e){
}*/
        Test.stopTest();
    }
    
}