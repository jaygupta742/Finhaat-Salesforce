@istest
public class CreateAccountFromLead_Test {
@Istest
    Public Static void testdata(){
        lead_Owner__c loa = new lead_Owner__c();
        loa.Name = 'Test';
        loa.Owner_Id__c = '0055j00000CF8ICAA1';
        insert loa;
        
        Lead L=New Lead();
        l.FirstName = 'nAME';
        L.LastName='gd';
        l.LeadSource ='New';
        
        
        insert l;
    }
}