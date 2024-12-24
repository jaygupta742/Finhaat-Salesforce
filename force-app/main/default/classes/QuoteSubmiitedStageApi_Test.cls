@IsTest
public class QuoteSubmiitedStageApi_Test {
@Istest
    Public static void testdate(){
        
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
        opp.CloseDate = date.today()+10;
        insert opp;
        
        ContentVersion cv=new ContentVersion();
        cv.Pathonclient='name';
        cv.Title ='title';
        cv.VersionData = blob.valueof('ff'); 
        insert cv;
           String contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        QuoteSubmiitedStageApi.DeleteAttachments(New String[]{''});
        QuoteSubmiitedStageApi.sendDoc(opp.id, contentDocumentId);
    }
}