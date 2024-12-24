@isTest
public class TicketTrigger_helper_Test {
	@isTest
    public static void tempWar_Test(){
        Account con = new Account();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.WhatsApp_No__c = '9579853991';
        insert con;
        
      	Ticket__c tc = new Ticket__c();
      	tc.Account__c = con.Id;
        tc.Stage__c = 'Quotation';
        insert tc;       
        
        tc.Stage__c = 'Policy Issued';
        update tc;       
        
        Test.startTest();
        TicketWhatsAppChatController.tempwap(tc.Id);
        Test.stopTest();
    }
}