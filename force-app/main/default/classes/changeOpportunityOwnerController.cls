//Create by vishal singh, On 30-04-2024 
public without sharing class changeOpportunityOwnerController{
    
    public List<Opportunity> selInvcLst;
    
    public String filterId {get; set;}
    public list<String> selectedIds {get; set;}
    public String sessionId {get; set;}
    
    public changeOpportunityOwnerController(ApexPages.StandardSetController controller){
        filterId = controller.getFilterId();
        system.debug(filterId);
        system.debug(controller.getSelected());

        list<SObject> selectedIds = controller.getSelected();
        this.selectedIds = new list<String>();

        for ( SObject Opportunity : selectedIds ){
            this.selectedIds.add(Opportunity.Id);
        }
        this.sessionId = UserInfo.getSessionId().substring(15);

        system.debug(UserInfo.getSessionId().substring(15));
    }

    public PageReference redirectToLC(){

        String orgDomain = Url.getSalesforceBaseUrl().toExternalForm();
       	this.sessionId = UserInfo.getSessionId().substring(15);

        system.debug(filterId);
        system.debug(selectedIds);
        system.debug(this.selectedIds.size());
        system.debug(sessionId);
        String ccd = orgDomain + '/lightning/cmp/c__changeAccountOwnerWrapper?c__filterName=' + filterId + '&c__selectedAccounts=' + JSON.serialize(selectedIds) + '&c__sessionId=' + sessionId;
        PageReference pgReturnPage = new PageReference(ccd);
        pgReturnPage.setRedirect(true);

        return pgReturnPage;
    }

    @AuraEnabled
    public static string getRecordsUsingRestApi(String filterId, String sessionId){
        try{

            Http http = new Http();
            HTTPRequest httpReq = new HTTPRequest();
            String orgDomain = Url.getSalesforceBaseUrl().toExternalForm();

            String endpoint = orgDomain + '/services/data/v58.0/sobjects/Opportunity/listviews/' + filterId + '/describe';

            httpReq.setEndpoint(endpoint);
            httpReq.setMethod('GET');
            httpReq.setHeader('Content-Type', 'application/json; charset=UTF-8');
            httpReq.setHeader('Accept', 'application/json');

            String Authorization = 'Bearer ' + sessionId;

            httpReq.setHeader('Authorization', Authorization);


            // if ( Test.isRunningTest() ){
            //     return 'test';
            // }

            HTTPResponse httpRes = http.send(httpReq);

            String ResponseBody = httpRes.getBody();
            Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(ResponseBody);


            String query = (String) mapResponse.get('query');

            List<SObject> records = Database.query(query);

            return JSON.serialize(records);

        } catch ( Exception e ){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string changeOwner(String listOfAccountInJson, String newOwnerId){
        try{

            list<Opportunity> finalOpportunityList = new list<Opportunity>();

            list<String> accountIdList = (list<String>)JSON.deserialize(listOfAccountInJson, list<String>.class);


            for ( String accountId : accountIdList ){
                finalOpportunityList.add(new Opportunity(
                    Id = accountId, 
                    OwnerId = newOwnerId
                ));
            }
            update finalOpportunityList;

            System.debug(finalOpportunityList);
            return 'success';

        } catch (Exception e) {
            System.debug('An exception occurred at line: ' + e.getLineNumber());
            System.debug('Exception message: ' + e.getMessage());
            throw new AuraHandledException('An error occurred: ' + e.getMessage());
        }

    }

}