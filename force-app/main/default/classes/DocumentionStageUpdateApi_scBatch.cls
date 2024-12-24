Global class DocumentionStageUpdateApi_scBatch  Implements Database.Batchable<Sobject>, Database.AllowsCallouts{
    Public set<Id> oppIds;
    Global DocumentionStageUpdateApi_scBatch(Set<Id> ids){
        this.oppIds=ids;
    }
    
    global database.queryLocator start(Database.BatchableContext bc){
        
        return database.getqueryLocator('Select id,AccountId,stageName,Quote_Accepted__c, Mandate_Signed__c ,File_Uploaded_Response__c, Discovery_Stage_Response__c,Mandate_Singed_Response__c,Status_Update_Response__c from Opportunity Where Id In:oppids'); 
    }
    
    Global Void execute(Database.batchableContext bc, list<Opportunity> oplist){
        Deal_Api_UniqueReqId__c  un=[Select id,Unique_ID__c from Deal_Api_UniqueReqId__c  limit 1];
        try{   For(Opportunity opp:oplist){
            //  String js2='{  "username": "finhaat",  "password": "sign5412",  "leadName": "svasti",  "leadId": "eo-cghsk128se4543",  "requestId": "172542REQ",  "documentId": "MDL01",  "signersDetail":     {      "signerEmail": "abc@finhaat.in",      "signerName": "Shahrukh kazi",      "signerMobile": "**********",      "signType": "ELT",      "designation": "Designation Developer     "    }}';
            string JsonBody=getBody(opp.stageName,opp,un);
            // system.debug('JsonBody '+JsonBody);
            if(JsonBody !=''){
                HttpRequest req=New HttpRequest(); 
                req.SetEndPoint(system.label.Finhat_Api_Endpoint+getBodyEndPoint(opp.StageName));
                req.SetMethod('POST');
                req.SetHeader('content-type', 'application/json'); 
                req.SetBody(JsonBody);
                Http http=new http();
                httpResponse res=Http.Send(req);
                un.Unique_ID__c ++;
                update un;
                system.debug('Get Reponse '+res);
                system.debug('Get Reponse '+res.getbodyasblob().toString());
                system.debug('get Status Code '+res.GetStatusCode());
                if(opp.StageName =='Discovery' && opp.Mandate_Signed__c  == false){
                    opp.Mandate_Singed_Response__c = res.getbodyasblob().toString();
                    Map<string,Object> resp_map=(Map<String,Object>)JSON.deserializeuntyped(res.getbodyasblob().toString());
                    if(resp_map.get('message') == 'signed')opp.Mandate_Signed__c =true; 
                }
                if(opp.StageName =='Quote Accepted') {
                    opp.Status_Update_Response__c = res.getbodyasblob().toString();
                    Map<string,Object> resp_map=(Map<String,Object>)JSON.deserializeuntyped(res.getbodyasblob().toString());
                    if(resp_map.get('message') == 'signed')opp.StageName ='Quote Accepted'; opp.Quote_Accepted__c = true;
                } 
            } 
        }
        update oplist;
           }
        catch(exception e){
            
            un.Unique_ID__c ++;
                update un;
            system.debug('get error line '+e.GetLineNumber());
            system.debug('get error Msg '+e.getMessage());
        }
    }
    
    Global void finish(Database.batchableContext bc){
        system.debug('InFinish Method opp ids '+oppIds.Size());
        
    }
    public static string getBodyEndPoint(String Stage ){
        system.debug('Checking Stage '+Stage);
        if(Stage == null ) return ''; 
        else return 'api/esign/status'; 
    }
    public static string getBody(String Stage, Opportunity opp, Deal_Api_UniqueReqId__c  un){
        system.debug('Checking Stage '+Stage); 
        if(Stage == null ) return '';
        Map<String, Object> jsonMap = new Map<String, Object>();
        if(Stage =='Quote Accepted'){
            Map<String, Object> getdocuploadrespose=(Map<String,Object>)JSON.deserializeuntyped(opp.File_Uploaded_Response__c);
            jsonMap.put('username', 'finhaat');
            jsonMap.put('password', 'sign5412');
            jsonMap.put('leadId', opp.AccountId); 
            jsonMap.put('requestId',(string)getdocuploadrespose.get('requestId')); 
        }
        if(Stage =='Discovery' && opp.Mandate_Signed__c == false){
            Map<String, Object> getdocuploadrespose=(Map<String,Object>)JSON.deserializeuntyped(opp.Discovery_Stage_Response__c);
            jsonMap.put('username', 'finhaat');
            jsonMap.put('password', 'sign5412');
            jsonMap.put('leadId', opp.AccountId); 
            jsonMap.put('requestId',(string)getdocuploadrespose.get('requestId')); 
        } 
        return JSON.Serialize(jsonMap);
    } 
}