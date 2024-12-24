@istest
public class InComingDocsforOpp_Test {
    @istest
    public Static void test_method(){
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
        
        Opportunity opp1=New Opportunity();
        opp1.Name ='OppName';
        opp1.AccountId = acc.id;
        opp1.Contact__c = con.id;
        opp1.StageName ='RFQ';
        opp1.File_Uploaded_Response__c ='{"leadId":"001H4000004g2qzIAA","requestId":"deal006H4000003A0YnIAKv54","returnCode":"200","message":"Send for E-sign","success":"success"}';
        opp1.CloseDate = date.today()+10;
        insert opp1; 
        string jsonbody='{"leadId": "'+ acc.id+'",    "documentDetails": [        {            "documentName": "DocumentuploadLetter_6634b36cd1838f21fbbd95a6 (1).pdf",            "documentInBase64":"423242ou5u4u234230408403840"        }    ]}';
        Test.startTest();
        RestRequest req=New RestRequest();
        req.requestURI ='https://finhaatinsurancebrokingpvtltd--subhadeep1.sandbox.my.salesforce-sites.com/InboundMsg/services/apexrest/post_Documents';
        req.httpMethod  ='POST';
        req.requestBody  = blob.valueof(jsonbody);
        
        restContext.request = req;
        InComingDocsforOpp.getDocs();
        test.Stoptest(); 
    }
}