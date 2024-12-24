@istest
public class DiscoveryStageIntegration_Test {
    @istest
    Public static void testdate(){
        Test.startTest();
        Deal_Api_UniqueReqId__c dd=New Deal_Api_UniqueReqId__c();
        dd.Name='uniqName';
        dd.Unique_ID__c =1;
        insert dd;
        Account acc=New Account();
        acc.Name ='Account';
        acc.GST_No__c ='12131231312313';
        acc.BillingCity ='wardha';
        acc.BillingCountry ='INDIA';
        ACC.BillingPostalCode ='332233';
        acc.BillingState ='Maharashtra';
        acc.BillingStreet ='AT DDSS SSDD';
        INSERT acc;
        
        Contact con=New Contact();
        con.lastName='conname';
        con.AccountId = acc.id;
        con.Email ='s@gmail.com';
        con.MobilePhone ='5544667788';
        insert Con;
        
        Opportunity opp=New Opportunity();
        opp.Name ='OppName';
        opp.AccountId = acc.id;
        opp.Contact__c = con.id;
        opp.StageName ='Discovery';
        opp.Mandate_Signed__c = false;
        OPP.Discovery_Stage_Response__c ='{"leadId":"001H4000008Bv0yIAC","requestId":"deal006H4000003A0YiIAKs","returnCode":"450","message":"RequestId already Exist,please try new RequestId ","success":"false"}';
        opp.CloseDate = date.today()+10;
        insert opp;
        Opportunity opp1=New Opportunity();
        opp1.Name ='OppName';
        opp1.AccountId = acc.id;
        opp1.Contact__c = con.id;
        opp1.StageName ='On Boarding';
        opp1.CloseDate = date.today()+10;
        insert opp1;
        
        
      set<id>  ids=New set<id> {opp.id };
          id[] ids1=New id[]{};
                
                DiscoveryStageIntegration.sendpostmethod(ids1);
        
        Test.setMock(HttpCalloutMock.class, new setmockhttpforfinhaat());
        test.Stoptest();
        Database.executeBatch(New DiscoveryStageIntegration_Batch(ids),1);
    }
    
     @istest
    Public static void testdate1(){
        Test.startTest();
        Deal_Api_UniqueReqId__c dd=New Deal_Api_UniqueReqId__c();
        dd.Name='uniqName';
        dd.Unique_ID__c =1;
        insert dd;
        Account acc=New Account();
        acc.Name ='Account';
        acc.GST_No__c ='12131231312313';
        acc.BillingCity ='wardha';
        acc.BillingCountry ='INDIA';
        ACC.BillingPostalCode ='332233';
        acc.BillingState ='Maharashtra';
        acc.BillingStreet ='AT DDSS SSDD';
        INSERT acc;
        
        Contact con=New Contact();
        con.lastName='conname';
        con.AccountId = acc.id;
        con.Email ='s@gmail.com';
        con.MobilePhone ='5544667788';
        insert Con;
        
        Opportunity opp=New Opportunity();
        opp.Name ='OppName';
        opp.AccountId = acc.id;
        opp.Contact__c = con.id;
        opp.StageName ='Quote Accepted';
        opp.CloseDate = date.today()+10;
        OPP.File_Uploaded_Response__c ='{"leadId":"001H4000008Bv0yIAC","requestId":"deal006H4000003A0YiIAKs","returnCode":"450","message":"RequestId already Exist,please try new RequestId ","success":"false"}';
        insert opp;
        Opportunity opp1=New Opportunity();
        opp1.Name ='OppName';
        opp1.AccountId = acc.id;
        opp1.Contact__c = con.id;
        opp1.StageName ='On Boarding';
        opp1.CloseDate = date.today()+10;
        insert opp1;
        
        
        set<id>  ids=New set<id> {opp1.id };
          id[] ids1=New id[]{};

                DocumentionStageUpdateApi_sc ds=New DocumentionStageUpdateApi_sc();
        ds.Execute(null);
                DiscoveryStageIntegration.sendpostmethod(ids1); 
        Test.setMock(HttpCalloutMock.class, new setmockhttpforfinhaat());
        test.Stoptest();
        Database.executeBatch(New DiscoveryStageIntegration_Batch(ids),1);
    }
}