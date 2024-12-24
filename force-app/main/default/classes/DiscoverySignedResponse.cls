public class DiscoverySignedResponse {
    @AuraEnabled
    public static String check_signed_status(string recid){ 
            Deal_Api_UniqueReqId__c  un=[Select id,Unique_ID__c from Deal_Api_UniqueReqId__c  limit 1];
        try{
        
            string msg='Already signed..!!';
            Opportunity opp =[SELECT Id, AccountId, StageName, Mandate_Signed__c, File_Uploaded_Response__c, Mfi_Completed__c,On_Boarding_Response__c,MFI_Status_Response__c,
                              Discovery_Stage_Response__c, Mandate_Singed_Response__c, Status_Update_Response__c ,Quote_Accepted__c
                              FROM Opportunity 
                              WHERE Id =:recid 
                              AND (StageName = 'Quote Accepted' OR (StageName =:'Discovery') or (StageName =:'On Boarding'))
                             ];
            
            If(opp.StageName =='Quote Accepted' && opp.File_Uploaded_Response__c != null){
                string JsonBody=getBody(opp.stageName,opp,un);
                
                HttpRequest req=New HttpRequest(); 
                req.SetEndPoint(system.label.Finhat_Api_Endpoint+'api/esign/status');
                req.SetMethod('POST');
                req.SetHeader('content-type', 'application/json'); 
                req.SetBody(JsonBody);
               //   req.setTimeOut(120000);
                Http http=new http();
                httpResponse res=Http.Send(req);
                un.Unique_ID__c ++;
                update un;
                system.debug('Get Reponse '+res);
                system.debug('Get Reponse '+res.getbodyasblob().toString());
                system.debug('get Status Code '+res.GetStatusCode());
                opp.Status_Update_Response__c = res.getbodyasblob().toString();
                Map<string,Object> resp_map=(Map<String,Object>)JSON.deserializeuntyped(res.getbodyasblob().toString());
                if(resp_map.get('message') == 'signed'){
                    opp.StageName ='Quote Accepted';
                    opp.Quote_Accepted__c = true;
                }
                msg ='Praposal Status Is '+(string)resp_map.get('message');
            }
            if(opp.StageName == 'Discovery'  && opp.Discovery_Stage_Response__c  != null){
                string JsonBody=getBody(opp.stageName,opp,un);
                
                HttpRequest req=New HttpRequest(); 
                req.SetEndPoint(system.label.Finhat_Api_Endpoint+'api/esign/status');
                req.SetMethod('POST');
                req.SetHeader('content-type', 'application/json'); 
                req.SetBody(JsonBody);
                  //req.setTimeOut(120000);
                Http http=new http();
                httpResponse res=Http.Send(req);
                un.Unique_ID__c ++;
                update un;
                system.debug('Get Reponse '+res);
                system.debug('Get Reponse '+res.getbodyasblob().toString());
                system.debug('get Status Code '+res.GetStatusCode());
                opp.Mandate_Singed_Response__c = res.getbodyasblob().toString();
                Map<string,Object> resp_map=(Map<String,Object>)JSON.deserializeuntyped(res.getbodyasblob().toString());
                if(resp_map.get('message') == 'signed')opp.Mandate_Signed__c =true; 
                msg ='Mandate Status Is '+(string)resp_map.get('message');
            }
            
            if(opp.StageName == 'On Boarding' && opp.On_Boarding_Response__c  != null){
                string JsonBody=getBody(opp.stageName,opp,un);
                
                HttpRequest req=New HttpRequest(); 
                req.SetEndPoint(system.label.Finhat_Api_Endpoint+'api/esign/status');
                req.SetMethod('POST');
                req.SetHeader('content-type', 'application/json'); 
                req.SetBody(JsonBody);
               //   req.setTimeOut(120000);
                Http http=new http();
                httpResponse res=Http.Send(req);
                un.Unique_ID__c ++;
                update un;
                system.debug('Get Reponse '+res);
                system.debug('Get Reponse '+res.getbodyasblob().toString());
                system.debug('get Status Code '+res.GetStatusCode());
             opp.MFI_Status_Response__c = res.getbodyasblob().toString();
                Map<string,Object> resp_map=(Map<String,Object>)JSON.deserializeuntyped(res.getbodyasblob().toString());
                if(resp_map.get('message') == 'completed')opp.Mfi_Completed__c =true; 
                msg ='MFI Status Is '+(string)resp_map.get('message');
            }
            update opp;
            return msg;
        }
        catch(exception e){
              un.Unique_ID__c ++;
                update un;
            system.debug('get error line '+e.GetLineNumber());
            system.debug('get error Msg '+e.getMessage());
            throw new AurahandledException(e.getMessage());
        }
        
    }
    
    public static string getBody(String Stage, Opportunity opp, Deal_Api_UniqueReqId__c  un){
        system.debug('Checking Stage '+Stage); 
        if(Stage == null ) return '';
        Map<String, Object> jsonMap = new Map<String, Object>();
        if(Stage =='Quote Accepted' && opp.File_Uploaded_Response__c != null){
            Map<String, Object> getdocuploadrespose=(Map<String,Object>)JSON.deserializeuntyped(opp.File_Uploaded_Response__c);
            jsonMap.put('username', 'finhaat');
            jsonMap.put('password', 'sign5412');
            jsonMap.put('leadId', opp.AccountId); 
            jsonMap.put('requestId',(string)getdocuploadrespose.get('requestId')); 
        }
        if(Stage =='Discovery'  && opp.Discovery_Stage_Response__c  != null){
            Map<String, Object> getdocuploadrespose=(Map<String,Object>)JSON.deserializeuntyped(opp.Discovery_Stage_Response__c);
            jsonMap.put('username', 'finhaat');
            jsonMap.put('password', 'sign5412');
            jsonMap.put('leadId', opp.AccountId); 
            jsonMap.put('requestId',(string)getdocuploadrespose.get('requestId')); 
        } 
         if(Stage =='On Boarding'   && opp.On_Boarding_Response__c  != null){
            Map<String, Object> getdocuploadrespose=(Map<String,Object>)JSON.deserializeuntyped(opp.On_Boarding_Response__c);
            jsonMap.put('username', 'finhaat');
            jsonMap.put('password', 'sign5412');
            jsonMap.put('leadId', opp.AccountId); 
            jsonMap.put('requestId',(string)getdocuploadrespose.get('requestId')); 
        } 
        return JSON.Serialize(jsonMap);
    } 
}