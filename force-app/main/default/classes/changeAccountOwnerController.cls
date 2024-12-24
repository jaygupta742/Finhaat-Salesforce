public without sharing class changeAccountOwnerController{
    
    public List<Account> selInvcLst;
    
    public String filterId {get; set;}
    public list<String> selectedIds {get; set;}
    public String sessionId {get; set;}
    
    public changeAccountOwnerController(ApexPages.StandardSetController controller){
        filterId = controller.getFilterId();
        system.debug(filterId);
        system.debug(controller.getSelected());

        list<SObject> selectedIds = controller.getSelected();
        this.selectedIds = new list<String>();

        for ( SObject account : selectedIds ){
            this.selectedIds.add(account.Id);
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

            String endpoint = orgDomain + '/services/data/v58.0/sobjects/Account/listviews/' + filterId + '/describe';

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
    public static string changeOwner(Boolean openOpp, Boolean allOpp, Boolean contacts, String listOfAccountInJson, String newOwnerId){
        try{

            list<Opportunity> finalOpportunityList = new list<Opportunity>();
            list<Contact> finalContactList = new list<Contact>();
            list<Account> finalAccountList = new list<Account>();

            list<String> accountIdList = (list<String>)JSON.deserialize(listOfAccountInJson, list<String>.class);


            for ( String accountId : accountIdList ){
                finalAccountList.add(new Account(
                    Id = accountId, 
                    OwnerId = newOwnerId
                ));
            }

            if ( allOpp == true ){

                list<Opportunity> opportunityList = [Select OwnerId
                                                     From Opportunity
                                                     Where AccountId IN:accountIdList];


                for ( Opportunity opportunity : opportunityList ){
                    opportunity.OwnerId = newOwnerId;
                    finalOpportunityList.add(opportunity);
                }


            } else if ( openOpp == true ){
                list<Opportunity> opportunityList = [Select OwnerId
                                                     From Opportunity
                                                     Where AccountId IN:accountIdList AND (StageName != 'Closed Won' OR StageName != 'Closed Lost')];

                for ( Opportunity opportunity : opportunityList ){
                    opportunity.OwnerId = newOwnerId;
                    finalOpportunityList.add(opportunity);
                }
            }

            if ( contacts == true ){
                list<Contact> contactList = [Select OwnerId
                                             From Contact
                                             Where AccountId IN:accountIdList];

                for ( Contact contact : contactList ){
                    contact.OwnerId = newOwnerId;
                    finalContactList.add(contact);
                }
            }


            update finalOpportunityList;
            update finalContactList;
            update finalAccountList;

            System.debug(finalOpportunityList);
            System.debug(finalContactList);

            return 'success';

        } catch ( Exception e ){
            throw new AuraHandledException(e.getMessage());
        }
    }

}