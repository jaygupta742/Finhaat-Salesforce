//Create by vishal singh, On 30-04-2024 
@isTest
public class changeOpportunityOwnerControllerTest {
    
    @isTest
    public static void testOne(){
        
        List<Account> accountsToTest = new List<Account>{ new Account(Name = 'Test Account 1'), new Account(Name = 'Test Account 2') };
            
            list<String> listOfAccountInJson = new list<String>();
        
        insert accountsToTest;
        List<Opportunity> oppListToTest = new List<Opportunity>{new Opportunity(Name = 'Test Opp 1', StageName = 'StageName', AccountId = accountsToTest[0].Id, CloseDate = Date.today().addDays(30))};
        insert oppListToTest;
        for(Opportunity opp : oppListToTest){
            listOfAccountInJson.add(opp.Id);
        }
        
        ApexPages.StandardSetController standardSetController = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id, Name FROM Opportunity]));
        standardSetController.setSelected(accountsToTest);
        Test.setMock(HttpCalloutMock.class, new HttpMockForOwnerChange());
        Test.startTest();
        changeOpportunityOwnerController controller = new changeOpportunityOwnerController(standardSetController);
        controller.redirectToLC();
        changeOpportunityOwnerController.getRecordsUsingRestApi('00B5i00000GLauuEAD','1234');
        changeOpportunityOwnerController.changeOwner(JSON.serialize(listOfAccountInJson), Userinfo.getUserId());
        changeOpportunityOwnerController.changeOwner(JSON.serialize(listOfAccountInJson), Userinfo.getUserId());
        Test.stopTest();
    }
    
    public class httpMockForOwnerChange implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            Datetime now = Datetime.now();
            Map<String, Object> mapQuery = new Map<String, Object>{ 'query' => 'Select Id from Account' };
                
                HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody(JSON.serialize(mapQuery));
            String endpoint = 'https://mapi.indiamart.com/wservce/crm/crmListing/v2';
            req.setEndpoint(endpoint);
            return res;
        }
    }
}