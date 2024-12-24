// Created By Ashish Kurzekar on 5>06>2024
@isTest
public class ticket_Attachments_test {
    @isTest
    public static void setData() {
        // Create account data
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Timelines__c = system.today();
        acc.Phone = '1234567890';
        acc.BillingCity = 'tstss';
        acc.BillingCountry = 'India';
        acc.BillingState = 'Maharastra';
        acc.BillingStreet = 'dfdfd';
        acc.BillingPostalCode = '232323';
        insert acc;
        
        // Create Ticket 
        Ticket__c tc = new Ticket__c();
        tc.Account__c = acc.Id;
        insert tc;
        
        ContentVersion cVersion = new ContentVersion();
        cVersion.PathOnClient = 'test.txt';
        cVersion.Title = 'Test Document';
        cVersion.VersionData = Blob.valueOf('Test Content');        
        insert cVersion;
        
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId; 
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;
        cDocLink.LinkedEntityId = acc.Id;
        cDocLink.ShareType = 'V'; // Use Viewer permission
        cDocLink.Visibility = 'AllUsers'; // AllUsers
        insert cDocLink; 
        
        // Call methods for testing
        ticket_Attachments.checkFileType('text/plain');
        
        ContentVersion opp = [SELECT Id FROM ContentVersion LIMIT 1];
        Account opps = [SELECT Id FROM Account LIMIT 1];
        
        List<String> selectAttachmentId = new List<String>{opp.Id};
         
        Test.startTest();
        ticket_Attachments.attachToTicket(acc.Id, tc.Id, selectAttachmentId);
        ticket_Attachments.getDocumentsForOpportunity(acc.Id);
        ticket_Attachments.getAllTickets(tc.Id);
        Test.stopTest();
    }
}