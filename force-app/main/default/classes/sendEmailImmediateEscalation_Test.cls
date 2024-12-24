//created by vishal singh on 12-12-2024
@isTest
public class sendEmailImmediateEscalation_Test {
    @isTest
    static void testSendEmailOnEscalation() {
        // Create test data
        User manager = new User(
            FirstName = 'Sanket',
            LastName = 'Prabhu',
            Email = 'manager@test.com',
            Username = 'manager@test.com' + System.currentTimeMillis(),
            Alias = 'tmanager',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert manager;

        User owner = new User(
            FirstName = 'Sanket',
            LastName = 'Prabhu',
            Email = 'owner@test.com',
            Username = 'owner@test.com' + System.currentTimeMillis(),
            Alias = 'towner',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            ManagerId = manager.Id
        );
        insert owner;

        // Create Ticket__c records
        Ticket__c oldTicket = new Ticket__c(
            Stage__c = 'Resolved',
            OwnerId = owner.Id
        );
        insert oldTicket;

        Ticket__c newTicket = new Ticket__c(
            Id = oldTicket.Id,
            Stage__c = 'Escalated',
            Escalated_Date__c = Date.today(),
            OwnerId = owner.Id
        );

        // Simulate trigger context
        List<Ticket__c> newTickets = new List<Ticket__c> { newTicket };
        Map<Id, Ticket__c> oldTicketMap = new Map<Id, Ticket__c> { oldTicket.Id => oldTicket };

        // Test sendEmailOnEscalation method
        Test.startTest();
        sendEmailImmediateEscalation.sendEmailOnEscalation(newTickets, oldTicketMap);
        Test.stopTest();
    }
    
    @isTest
    public static void tempWar_Test(){
        Account con = new Account();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.WhatsApp_No__c = '9579853991';
        insert con;
        
      	Ticket__c tc = new Ticket__c();
      	tc.Account__c = con.Id;
        tc.Stage__c = 'Ticket Raised';
        insert tc;       
        
        tc.Stage__c = 'Resolved';
        update tc;       
        
        Test.startTest();
        TicketWhatsAppChatController.tempwap(tc.Id);
        Test.stopTest();
    }
}