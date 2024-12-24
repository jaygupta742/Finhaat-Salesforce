@istest
public class TicketNotificationForAccount_test {
    public Static testMethod Void gettesdata(){
        Id fwInvestorRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'FW_Investor' AND SObjectType = 'Account' LIMIT 1].Id;
        Account acc = New Account();
        acc.RecordTypeId = fwInvestorRecordTypeId;
        acc.LastName = 'testing fw Account';
        insert acc;
        List<Ticket__c> tklist = new List<Ticket__c>();
        Ticket__c tk = new Ticket__c();
        tk.Account__c = acc.id;
        tk.text__c = 'testing';
        tk.Remarks_By_Sales__c = 'teteddd';
        tklist.add(tk);
        //  insert tk;
        insert tklist;
        Map<Id, Ticket__c> oldMap = new Map<Id, Ticket__c>();
        for(Ticket__c t1k : tklist){
            oldMap.put(t1k.Account__c,t1k);
        }
            test.SetMock(HttPCalloutMock.Class , New Send_Wap_Class_Mock());
        try {
            TicketNotificationForAccount.getNotification(tklist,oldMap);
        }
        catch(Exception e) {
            //  Block of code to handle errors
        }
        
        
    }
    
}