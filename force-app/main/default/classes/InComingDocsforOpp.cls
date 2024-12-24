/* Created Date : 06/05/2024 , Created By : Suraj , Created For , Need to upload Docs From another system
*/ 
@RestResource(urlMapping='/post_Documents/*')
Global without Sharing class InComingDocsforOpp {
    @HttpPost
    Global static String getDocs(){
        string errroMsg='Success';
        try{ 
            string jsonBody = RestContext.request.requestBody.toString(); 
            system.debug('jsonBody '+jsonBody);
            Map<String, Object> get_Res = (MAp<String , Object>)JSON.deserializeUntyped(jsonbody);
            system.debug('The leadId is '+ get_Res.get('leadId'));
            if(get_Res.get('leadId') != null && get_Res.get('leadId') != ''){
                set<String> ids=New Set<String>{(string)get_Res.get('leadId')};
                    List<Account> acclist=[Select id from Account where id IN:ids];
                system.debug('acclist '+acclist);
                if(acclist.size()>0){
                    try {
                        Opportunity opp=[Select id, AccountId From Opportunity Where AccountId =: acclist[0].id Order by CreatedDate Desc Limit 1];
                        system.debug('opportunity '+opp);
                        
                        List<Object> docList = (List<Object>) get_Res.get('documentDetails');
                        system.debug('docList.Size()>0 '+ docList.Size());
                        list<ContentVersion> cvlist=New List<ContentVersion>();
                        if(docList.Size()>0){
                            for(Object doc:doclist){
                                map<string,Object> item=(Map<string,Object>)doc;
                                ContentVersion cv=New ContentVersion();
                                cv.VersionData = EncodingUtil.base64Decode((string)item.get('documentInBase64')); 
                                cv.PathOnClient = (string)item.get('documentName');
                                
                                cv.FirstPublishLocationId = opp.id;
                                cvlist.add(cv);
                                //insert cv;
                            }
                            insert cvlist;
                        }                        else{errroMsg ='Documents Not found...!!';  }
                    }                    catch(exception e){errroMsg ='For this leadId Opportunity Not Found ...!!' +'  '+e.getMessage()+' '+e.getLineNumber(); }
                }                else{errroMsg ='Lead Id Not Found...!!';  }
            }
            else{                errroMsg ='Lead Id Should not be Empty...!!';              }
        }
        catch(exception e){            system.debug('get error '+e.getMessage()+' on line '+e.getLineNumber());            errroMsg ='get error '+e.getMessage()+' on line '+e.getLineNumber();
        }
        return errroMsg;
    }
}