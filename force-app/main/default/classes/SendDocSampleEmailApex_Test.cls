@isTest
public class SendDocSampleEmailApex_Test {
    @isTest
    Public static void testSampleEmail(){
        Account testAccount = new Account();
        String RecTypeIdacc3= [select Id from RecordType where (Name='FW Partner')and(SobjectType='Account')].Id;
        testAccount.LastName = 'Test Acc';
        testAccount.FirstName = '123';
        testAccount.RecordTypeId=RecTypeIdacc3;
        insert testAccount;
        
        Required_Documents__c doc1 = new Required_Documents__c(
            Account__c = testAccount.Id,
            Name = 'Document 1',
            Status__c = 'Submitted'
        );
        insert doc1;
        
        ContentDocument doc = new ContentDocument();
        //insert doc;
        Attachment new_att = new Attachment();
        new_att.Body = blob.valueOf('sdfd');
        new_att.Name = 'att Name';
        new_att.ParentId = testAccount.Id;
        insert new_att;
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = new_att.Name;//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        //cVersion.OwnerId = wat1.OwnerId;//Owner of the file
        cVersion.Title = new_att.Name;//Name of the file
        cVersion.VersionData = new_att.Body;//File content
        
        string[] lstDocumentId=New String[]{cVersion.ContentDocumentId};
            String ccaddress = '[{"emailId": "s@gmail.com"}, {"emailId": "ss@gmail.com"}]';
                String recipients = '[{"emailId": "s@gmail.com"}, {"emailId": "ss@gmail.com"}]';
        
        Test.startTest();
        SendDocSampleEmailApex.sendtoWhatsApp(testAccount.Id, doc1.Id);
        String result = SendDocSampleEmailApex.getStudentEmail(testAccount.Id);
        SendDocSampleEmailApex.DeleteAttachments(new List<String>{doc.Id});
        SendDocSampleEmailApex.sendEmailmethod(
            'Test Subject',
            '<p>Test Body</p>',
            String.valueOf(recipients),
            String.valueOf(ccaddress),
            Json.serialize(lstDocumentId),
            testAccount.Id,
            true
        );
        Test.stopTest();
    }
}