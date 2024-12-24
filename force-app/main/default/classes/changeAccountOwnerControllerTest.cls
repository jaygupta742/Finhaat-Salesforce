@isTest
public class changeAccountOwnerControllerTest {
    
    @isTest
    public static void testOne(){
        
        List<Account> accountsToTest = new List<Account>{ new Account(Name = 'Test Account 1'), new Account(Name = 'Test Account 2') };
            
            list<String> listOfAccountInJson = new list<String>();
        
        insert accountsToTest;
        
        for(Account acc : accountsToTest){
            listOfAccountInJson.add(acc.Id);
        }
        
        ApexPages.StandardSetController standardSetController = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id, Name FROM Account]));
        standardSetController.setSelected(accountsToTest);
        Test.setMock(HttpCalloutMock.class, new HttpMockForOwnerChange());
        Test.startTest();
        ChangeAccountOwnerController controller = new ChangeAccountOwnerController(standardSetController);
        controller.redirectToLC();
        ChangeAccountOwnerController.getRecordsUsingRestApi('00B5i00000GLauuEAD','1234');
        ChangeAccountOwnerController.changeOwner(true, true, true, JSON.serialize(listOfAccountInJson), Userinfo.getUserId());
        ChangeAccountOwnerController.changeOwner(true, false, true, JSON.serialize(listOfAccountInJson), Userinfo.getUserId());
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