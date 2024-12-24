@istest
public class DiscoverySignedResponse_Test {
    @istest
    Public static void testdate(){
         Test.setMock(HttpCalloutMock.class, new setmockhttpforfinhaat());
      
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
      //  insert opp;
        Opportunity opp1=New Opportunity();
        opp1.Name ='OppName';
        opp1.AccountId = acc.id;
        opp1.Contact__c = con.id;
        opp1.StageName ='Quote Accepted';
        opp1.File_Uploaded_Response__c ='{"leadId":"001H4000004g2qzIAA","requestId":"deal006H4000003A0YnIAKv54","returnCode":"200","message":"Send for E-sign","success":"success"}';
         opp1.CloseDate = date.today()+10;
        insert opp1; 
     Test.startTest();
        try{  DiscoverySignedResponse.check_signed_status(opp1.id);}catch(exception e){}
         // 
      //  DiscoverySignedResponse.check_signed_status(opp1.id); 
        test.Stoptest();
        
    }
        @istest
    Public static void testdate1(){
         Test.setMock(HttpCalloutMock.class, new setmockhttpforfinhaat());
      
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
        opp.StageName ='Lead';
        opp.Mandate_Signed__c = false;
        OPP.Discovery_Stage_Response__c ='{"leadId":"001H4000004g2qzIAA","requestId":"deal006H4000003A0YnIAKv543","returnCode":"200","message":"Send for E-sign","success":"success"}';
        opp.CloseDate = date.today()+10;
       insert opp;
        opp.StageName ='Discovery';
        update opp;
     Test.startTest();
        DiscoverySignedResponse.check_signed_status(opp.id);
         // 
      //  DiscoverySignedResponse.check_signed_status(opp1.id); 
        test.Stoptest();
        
    }
    
    
      @istest
    Public static void testdate2(){
         Test.setMock(HttpCalloutMock.class, new setmockhttpforfinhaat());
      
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
        opp.StageName ='On Boarding';
        opp.Mfi_Completed__c = false;
        OPP.On_Boarding_Response__c ='{"leadId":"001H4000004g2qzIAA","requestId":"deal006H4000003A0YnIAKv542","returnCode":"200","message":"Send for E-sign","success":"success"}';
        opp.CloseDate = date.today()+10;
       insert opp;
        
     Test.startTest();
        try{ DiscoverySignedResponse.check_signed_status(opp.id);}catch(exception e){}
         // 
      //  DiscoverySignedResponse.check_signed_status(opp1.id); 
        test.Stoptest();
        
    }
}