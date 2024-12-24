/*Created By :Suraj , Created Date : 30/04/2024, Description , This is apex class when upload the document then need to hit the document api
*/ 
public class QuoteSubmiitedStageApi {
    
    @AuraEnabled
    public static void DeleteAttachments(List<String> lstDocumentId){
        
        List<ContentDocument> lstAttachments = [SELECT Id, Title
                                                FROM ContentDocument
                                                WHERE Id IN:lstDocumentId];
        Delete lstAttachments;
        
    }
    
    @AuraEnabled
    Public static String sendDoc( String recordId, String docid){
           Deal_Api_UniqueReqId__c  un=[Select id,Unique_ID__c from Deal_Api_UniqueReqId__c  limit 1];
        try{
            Opportunity opp   =[Select id,AccountId,stageName,File_Uploaded_Response__c,File_Uploaded__c, Account.Name,Contact__r.Name, Contact__r.Email,Contact__r.MobilePhone,Contact__r.Title
                                from Opportunity Where Id=:recordId];
            system.debug(docid);
            //    List<String> lstDocumentId = (List<String>)JSON.deserialize(docid, List<String>.class);
            //  system.debug(lstDocumentId);
            if(docid !=''){ 
                system.debug('123 '+docid); 
                
                ContentVersion cv = [SELECT Id, Title, FileType, ContentDocumentId, VersionData, PathonClient
                                     FROM ContentVersion
                                     WHERE ContentDocumentId =:docid
                                    ];
             
                string JsonBody=getBody(opp.StageName, opp,cv,un);
                
                if(JsonBody !=''){
                    
                    HttpRequest req=New HttpRequest();
                    
                    req.SetEndPoint(system.label.Finhat_Api_Endpoint+'api/esign/signRequest');
                    req.SetMethod('POST');
                    req.SetHeader('content-type', 'application/json');
                    req.setTimeOut(120000);
                    req.SetBody(JsonBody);
                    Http http=new http();
                    try{ httpResponse res=Http.Send(req); 
                        system.debug('Get Reponse '+res);
                        system.debug('get Status Code '+res.GetStatusCode());
                        system.debug('Get Reponse '+res.getbodyasblob().toString());
                        un.Unique_ID__c ++;  
                        update un; 
                        opp.File_Uploaded_Response__c =res.getbodyasblob().toString();
                        Map<string,Object> resp_map=(Map<String,Object>)JSON.deserializeuntyped(res.getbodyasblob().toString());
                        if(resp_map.get('returnCode') == '200')   opp.File_Uploaded__c = true;
                        
                       }catch(exception e){
                           system.debug('get error on http  '+e.getMessage());
                           system.debug('get Line Number http'+e.getLineNumber());
                           un.Unique_ID__c ++;  
                           update un;   
                           // opp.StageName='Quote Accepted';
                       }
                    
                    update opp;
                    
                    ContentVersion cv1=New ContentVersion();
                    cv1.Title = cv.Title+cv.FileType;
                    cv1.PathOnClient = cv.PathOnClient;
                    cv1.VersionData = cv.VersionData;
                    // cv1.FileType = cv.FileType;
                    insert cv1;
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.LinkedEntityId = opp.id; // Quote Id
                    cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv1.Id].ContentDocumentId;
                    cdl.ShareType = 'V'; // 'V' for Viewer Access
                    cdl.Visibility = 'AllUsers'; // You can adjust visibility as needed
                    try{ insert cdl; system.debug('insede insert '+cdl.Id);}catch(exception e){
                        system.debug(e.getMessage());
                    }
                    
                    
                } 
            }
            return 'Success';
        }
        catch(exception e){
              
            un.Unique_ID__c ++;
            update un;
            system.debug('get error '+e.getMessage());
            system.debug('get Line Number '+e.getLineNumber());
            throw New AurahandledException(e.getMessage());
        }
    }
    
    public static string getBody(String Stage, Opportunity opp,ContentVersion cv,Deal_Api_UniqueReqId__c un){
        system.debug('Checking Stage '+Stage+ 'EncodingUtil.base64Encode(cv.VersionData) '+EncodingUtil.base64Encode(cv.VersionData));
        
        if(Stage == null ) return '';
        Map<String, Object> jsonMap = new Map<String, Object>();
        Map<String, Object> docdetals = new Map<String, Object>();
        docdetals.put('documentName',cv.Title+'.'+cv.fileType);
        docdetals.put('documentInBase64',EncodingUtil.base64Encode(cv.VersionData));
        jsonMap.put('documentDetails',docdetals);
        String mobileno = Opp.Contact__r.MobilePhone.replaceAll('[^\\d]', '');
        mobileno = mobileno.length() > 10 ? mobileno.substring(mobileno.length() - 10) : mobileno;
        mobileno = mobileno;
        Map<String, Object> signersDetailMap = new Map<String, Object>();
        signersDetailMap.put('signerEmail',opp.Contact__r.Email);
        signersDetailMap.put('signerName',opp.Contact__r.Name);
        signersDetailMap.put('signerMobile',mobileno);
        signersDetailMap.put('signType', 'ELT');
        signersDetailMap.put('designation',opp.Contact__r.Title);
        
        // Adding the inner map to the main map
        jsonMap.put('signersDetail',signersDetailMap);
        
        jsonMap.put('username', 'finhaat');
        jsonMap.put('password', 'sign5412');
        jsonMap.put('leadName',opp.Account.Name);
        jsonMap.put('leadId',opp.AccountId);
        jsonMap.put('requestId','deal'+opp.id+'v'+(un.Unique_ID__c));
        jsonMap.put('documentId','PRO01');
        
        // Creating the inner map for "signersDetail"
        
        
        return JSON.Serialize(jsonMap);
    }
    
}