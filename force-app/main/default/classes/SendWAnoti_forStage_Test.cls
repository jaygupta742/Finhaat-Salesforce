@isTest
public class SendWAnoti_forStage_Test {
    @isTest
   Public static void testSendWap(){
        Account testAccount = new Account();
        testAccount.Name = 'Test Account1111';
        testAccount.WhatsApp_No__c = '1111111111';
        insert testAccount;
        Whatsapp_Templates__c wtt=New Whatsapp_Templates__c();
       wtt.Name ='Code Created';
       wtt.Text__c ='test';
       insert wtt;
        Account testAccount2 = new Account();
        testAccount2.LastName = 'Test Account2222';
        testAccount2.PersonMobilePhone = '2222222222';
       testAccount2.WhatsApp_No__c = '7798056741';
       testAccount2.Stage__c = 'Code Created';
        Id recordTypeId = [SELECT Id
                           FROM RecordType
                           WHERE SObjectType = 'Account' AND Name = 'POS' AND IsPersonType = true
                           LIMIT 1].Id;
        testAccount2.RecordTypeId = recordTypeId;
        insert testAccount2; 
           Whatsapp_Templates__c wt = new Whatsapp_Templates__c();
        wt.name = 'Wlecome Template For Account<name><code>';
        wt.Text__c = 'test';
        insert wt;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Send_Wap_Class_Mock());
     //   Send_WA_In_Account.tempwap();
        try{
            SendWAnoti_forStage.sendnotification(New String[]{testAccount2.Id});
          //  Send_Wap_Class.send_wap(testAccount2.PersonMobilePhone, 'Test SMS', 'Account', testAccount2.Id, cids);
        } catch ( Exception e ){
        }
        try{
          //  Send_WA_In_Account.onsave(String.valueof(testAccount2.id), 'text_body', contentDocumentId);
        } catch ( Exception e ){
        }
       
        
        /*  try{
Send_Wap_Class.send_wap(testAccount2.PersonMobilePhone, 'Test SMS', 'Account', tc.Id);
}
catch(Exception e){
}*/
        Test.stopTest();
    }
    
}