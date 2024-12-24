@isTest
public class OpportunityTriggerTEST {
    @isTest
    static void testPolicyCreatedToTraining1() {
        Deal_Api_UniqueReqId__c dau = new Deal_Api_UniqueReqId__c(Name = 'adkf', Unique_ID__c = 0011);insert dau;
        
        Opportunity opp = new Opportunity(StageName = 'Lead', Name='Test create1', closeDate = system.today());insert opp;
        
        opp.StageName = 'Discovery';
        opp.Mandate_Signed__c = false;
        opp.All_Documents_Collected__c = false;
        opp.Mfi_Completed__c = false;
        opp.Quote_Accepted__c = false;
        Test.startTest();
        update opp;
        Test.stopTest();
    }
    /*@isTest
    static void testPolicyCreatedToTraining2() {
        Deal_Api_UniqueReqId__c dau = new Deal_Api_UniqueReqId__c(Name = 'adkf', Unique_ID__c = 0011);insert dau;
        
        Opportunity opp = new Opportunity(StageName = 'Discovery', Name='Test create1', closeDate = system.today());insert opp;
        
        opp.StageName = 'RFQ';
        opp.Mandate_Signed__c = false;
        opp.All_Documents_Collected__c = false;
        opp.Mfi_Completed__c = false;
        opp.Quote_Accepted__c = false;
        Test.startTest();
        update opp;
        Test.stopTest();
    }*/
}