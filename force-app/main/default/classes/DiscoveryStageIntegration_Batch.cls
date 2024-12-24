/* Created By Suraj , CreaTeD date: 30/04/2024, description : Need to call out finhaat Api to post the data
*/ 
Global class DiscoveryStageIntegration_Batch Implements Database.Batchable<Sobject>, Database.AllowsCallouts{
    Public set<Id> oppIds;
    Global DiscoveryStageIntegration_Batch(Set<Id> ids){
        this.oppIds=ids;
    }
    
    global database.queryLocator start(Database.BatchableContext bc){
        
        return database.getqueryLocator('Select id,AccountId,stageName,On_Boarding_Response__c,Account.PAN_No__c,File_Uploaded_Response__c,Discovery_Stage_Response__c,Status_Update_Response__c,Account.BillingPostalCode,Account.BillingState,Account.BillingStreet,Account.BillingCity, Account.Name, Account.GST_No__c,Contact__r.Name, Contact__r.Email,Contact__r.MobilePhone,Contact__r.Title from Opportunity Where Id In:oppids'); 
    }
    Global Void execute(Database.batchableContext bc, list<Opportunity> oplist){
        Deal_Api_UniqueReqId__c  un=[Select id,Unique_ID__c from Deal_Api_UniqueReqId__c  limit 1];
        try{     For(Opportunity opp:oplist){
            //  String js2='{  "username": "finhaat",  "password": "sign5412",  "leadName": "svasti",  "leadId": "eo-cghsk128se4543",  "requestId": "172542REQ",  "documentId": "MDL01",  "signersDetail":     {      "signerEmail": "abc@finhaat.in",      "signerName": "Shahrukh kazi",      "signerMobile": "**********",      "signType": "ELT",      "designation": "Designation Developer     "    }}';
            string JsonBody=getBody(opp.stageName,opp,un);
            // system.debug('JsonBody '+JsonBody);
            if(JsonBody !=''){
                HttpRequest req=New HttpRequest();
                
                req.SetEndPoint(system.label.Finhat_Api_Endpoint+getBodyEndPoint(opp.StageName));
                req.SetMethod('POST');
                req.SetHeader('content-type', 'application/json');
                req.setTimeOut(120000);
                req.SetBody(JsonBody);
                Http http=new http();
                httpResponse res=Http.Send(req);
                un.Unique_ID__c ++;
                update un;
                system.debug('Get Reponse '+res);
                system.debug('Get Reponse '+res.getbodyasblob().toString());
                system.debug('get Status Code '+res.GetStatusCode());
                if(opp.StageName =='Discovery')opp.Discovery_Stage_Response__c = res.getbodyasblob().toString();
                if(opp.StageName =='On Boarding')opp.On_Boarding_Response__c = res.getbodyasblob().toString();
                if(opp.StageName =='Quote Accepted') {
                    opp.Status_Update_Response__c = res.getbodyasblob().toString();
                    Map<string,Object> resp_map=(Map<String,Object>)JSON.deserializeuntyped(res.getbodyasblob().toString());
                    if(resp_map.get('message') == 'signed')opp.StageName ='Quote Accepted';
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
    
    public static string getBody(String Stage, Opportunity opp, Deal_Api_UniqueReqId__c  un){
        system.debug('Checking Stage '+Stage);
        
        if(Stage == null ) return '';
        Map<String, Object> jsonMap = new Map<String, Object>();
        if(Stage=='Discovery'){ 
            jsonMap.put('username', 'finhaat');
            jsonMap.put('password', 'sign5412');
            jsonMap.put('leadName',opp.Account.Name);
            jsonMap.put('leadId', opp.AccountId);
            jsonMap.put('requestId', 'deal'+opp.Id+'v'+(un.Unique_ID__c));
            jsonMap.put('documentId', 'MDL01');
            
            // Creating the inner map for "signersDetail"
            Map<String, Object> signersDetailMap = new Map<String, Object>();
            signersDetailMap.put('signerEmail',String.Valueof(opp.Contact__r.Email));
            signersDetailMap.put('signerName',String.Valueof(opp.Contact__r.Name));
            String mobileno = Opp.Contact__r.MobilePhone.replaceAll('[^\\d]', '');
            mobileno = mobileno.length() > 10 ? mobileno.substring(mobileno.length() - 10) : mobileno;
            mobileno = mobileno;
            signersDetailMap.put('signerMobile',mobileno);
            signersDetailMap.put('signType','ELT');
            signersDetailMap.put('designation',String.Valueof(opp.Contact__r.Title));
            
            // Adding the inner map to the main map
            jsonMap.put('signersDetail',signersDetailMap);
        }  
        if(Stage=='On Boarding'){
            jsonMap.put('username', 'finhaat');
            jsonMap.put('password', 'sign5412');
            jsonMap.put('leadName', opp.Account.Name);
            jsonMap.put('leadId', opp.AccountId); 
            jsonMap.put('requestId','deal'+opp.Id+'v'+(un.Unique_ID__c));
            jsonMap.put('shortName', 'SV');
           String DocumentType=(OPP.Account.GST_No__c == NULL)?'PAN':'GST';
            system.debug('DocumentType '+DocumentType);
            jsonMap.put('documentType',(OPP.Account.GST_No__c == NULL)?'PAN':'GST');
            jsonMap.put('documentNumber', (OPP.Account.GST_No__c == NULL)?OPP.Account.PAN_No__c:OPP.Account.GST_No__c);
            jsonMap.put('commAddrSameAsRegAddr', 'Y');
            
            Map<String, Object> registerAddress  = new Map<String, Object>();
            system.debug('opp.Account.BillingStreet '+opp.Account.BillingStreet+' '+opp.Account.BillingCity+' '+opp.Account.BillingState+' '+opp.Account.BillingPostalCode);
            registerAddress.put('address1',opp.Account.BillingStreet);
            registerAddress.put('address2',opp.Account.BillingStreet);
            registerAddress.put('city',Opp.Account.BillingCity); 
            registerAddress.put('state',opp.Account.BillingState); 
            registerAddress.put('pinCode',opp.Account.BillingPostalCode); 
            jsonMap.put('registerAddress',registerAddress);
            
            jsonMap.put('communicationAddress',registerAddress);
            
            String mobileno = Opp.Contact__r.MobilePhone.replaceAll('[^\\d]', '');
            mobileno = mobileno.length() > 10 ? mobileno.substring(mobileno.length() - 10) : mobileno;
            mobileno = mobileno;
            Map<String, Object> primaryContact = new Map<String, Object>();
            primaryContact.put('emailId',opp.Contact__r.Email);
            primaryContact.put('name',opp.Contact__r.Name);
            primaryContact.put('mobile',mobileno); 
            primaryContact.put('designation',opp.Contact__r.Title); 
            jsonMap.put('primaryContact',primaryContact); 
            List<documentDetails> documentDetails_list =New documentDetails []{};
                List<Required_Documents__c> rdlist=[Select id,Account__c,Name from Required_Documents__c 
                                                    where Account__c =: opp.AccountId and (Name LIKE:'%'+system.label.PAN_Name+'%' or 
                                                                                           Name LIKE:'%'+system.label.GST_Name+'%' or
                                                                                           Name LIKE:'%'+system.label.NEFT_Name+'%')];
            System.debug('Required_Documents__c List sie '+rdlist.Size());
            set<id> req_id=New set<id>();
            for(Required_Documents__c rd:rdlist){
                req_id.add(rd.Id);
            }
            List<Attachment> attlist=[Select id, Name , Body from Attachment where parentId in:req_id];
            for(Attachment att:attlist){ 
                system.debug('Attachment name '+ att.Name);
                documentDetails obj1=New documentDetails();
                obj1.documentName =att.Name;
                obj1.documentId =att.id;
                obj1.documentInBase64 =EncodingUtil.base64Encode(att.body);
                documentDetails_list.add(obj1);
            }
            
            
            jsonMap.put('documentDetails',documentDetails_list); 
        }
        if(Stage =='Quote Accepted'){
            Map<String, Object> getdocuploadrespose=(Map<String,Object>)JSON.deserializeuntyped(opp.File_Uploaded_Response__c);
            jsonMap.put('username', 'finhaat');
            jsonMap.put('password', 'sign5412');
            jsonMap.put('leadId', opp.AccountId); 
            jsonMap.put('requestId',(string)getdocuploadrespose.get('requestId'));
            
        }
        
        return JSON.Serialize(jsonMap);
    }
    
    public static string getBodyEndPoint(String Stage ){
        system.debug('Checking Stage '+Stage);
        if(Stage == null ) return '';
        if(Stage=='Discovery')return 'api/esign/signRequest';
        if(Stage=='On Boarding')return 'api/mfi/create';
        if(Stage=='Quote Accepted')return 'api/esign/status';
        return '';
    }
    
    
    public class documentDetails{
        public string documentName,documentId,documentInBase64;
    }
}