/*Last Modified by: Sougata Paul; Last Modified On: 20-02-2024; Description: Save and notify button added*/
public class AddRequiredDoc {
   /* @AuraEnabled
    public static DDM3__Education_History__c educationhistory(){
        DDM3__Education_History__c edu=[select Highest_level_of_Education__c  from DDM3__Education_History__c limit 1];
        return edu;
    }*/
    
      @AuraEnabled
    public static string getinstant(Id recId){
        /*
              List<wrapper> wrap = new List<wrapper>();
                Required_Documents__c rd = new Required_Documents__c();
                wrapper w = new wrapper(rd);
                w.name= '';
                w.instruction = '';
                wrap.add(w);
              return Json.serialize(wrap);
		*/
        System.debug('recordId===>'+recId);
         //String stages = 'FW Partner';
        try{
            String stages = [Select recordtype.Name from account where id =: recId].recordtype.Name;
            System.debug('stages===>'+stages);
            list<Master_Document__c> masterlist = [Select id, name, order__c, Stages__c, Instruction__c
                                                   from Master_Document__c where Stages__c like: '%'+stages+'%' order by order__c ASC];
           system.debug('List of Master Document : ' + masterlist);
            
            List<wrapper> wrap = new List<wrapper>();
            
            for(Master_Document__c md : masterlist){
                System.debug('get order '+md.Stages__c);
                Required_Documents__c rd = new Required_Documents__c();
                wrapper w = new wrapper(rd);
                w.name= md.Name;
                w.instruction = md.Instruction__c;
                wrap.add(w);
            }
            //system.debug('wrap');
            return Json.serialize(wrap);
        }
        catch(exception e){
            throw new AuraHandledException('something went wrong' + e.getMessage());
        } 
    }
  
    
    @AuraEnabled
    public static string getmasterdoc(String stages){
        try{
            list<Master_Document__c> masterlist = [Select id, name, order__c, Stages__c, Instruction__c
                                                   from Master_Document__c where Stages__c like: '%'+stages+'%' order by order__c ASC];
            system.debug('List of Master Document : ' + masterlist);
            
            List<wrapper> wrap = new List<wrapper>();
            
            for(Master_Document__c md : masterlist){
                System.debug('get order '+md.Stages__c);
                Required_Documents__c rd = new Required_Documents__c();
                wrapper w = new wrapper(rd);
                w.name= md.Name;
                w.instruction = md.Instruction__c;
                wrap.add(w);
            }
            system.debug('wrap');
            return Json.serialize(wrap);
        }
        catch(exception e){
            throw new AuraHandledException('something went wrong' + e.getMessage());
        } 
    }
    
    @AuraEnabled
    public static string onsave(String recid, string reqdoc,string stages) {
        try{
            system.debug('Application Id'+recid);
            system.debug('stages list'+stages);
            list<wrapper> wrap = (list<wrapper>)JSON.deserialize(reqdoc, list<wrapper>.class);
            
            list<Required_Documents__c> reqlist = new list<Required_Documents__c>();
            
            for(wrapper w : wrap) {
                Required_Documents__c rd= new Required_Documents__c();
                rd.Account__c= recid;
                rd.Name= w.name;
                rd.Instruction__c = w.instruction;
                rd.Stages__c= stages;
                rd.Status__c ='Yet To Submit';
                 rd.Stages__c = 'Other';
                reqlist.add(rd);
                
            }
            insert reqlist;
            
            return recid;
        }
        catch(Exception e) {
            system.debug('get line msg '+e.getMessage());
            system.debug('get line msg '+e.getLineNumber());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
    }
    
   /* @AuraEnabled
    public static string onsavenotify(String recid, string reqdoc,string stages) {
        try{
            system.debug('Application Id'+recid);
            system.debug('stages list'+stages);
            list<wrapper> wrap = (list<wrapper>)JSON.deserialize(reqdoc, list<wrapper>.class);
            
            list<Required_Documents__c> reqlist = new list<Required_Documents__c>();
            
            for(wrapper w : wrap) {
                Required_Documents__c rd= new Required_Documents__c();
                rd.Account__c= recid;
                rd.Name= w.name;
                rd.Instruction__c = w.instruction;
                rd.Stages__c= stages;
                rd.Status__c ='Yet To Submit';
                reqlist.add(rd);
                
            }
            insert reqlist;
            
            DDM3__Comments__c cmt = new DDM3__Comments__c();
            cmt.Account__c = recid;
            cmt.Name = 'We need to have some documents asap from your side .Kindly Provide these docs';
            cmt.Comment_By__c = 'Consultant';
            cmt.Comments_Status__c = 'Unseen';
            insert cmt;
            
            return recid;
        }
        catch(Exception e) {
            system.debug('get line msg '+e.getMessage());
            system.debug('get line msg '+e.getLineNumber());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
    }*/
    
    
    public class wrapper {
        public Required_Documents__c reqdoc {get;set;}
        public string name {get;set;}
        public String instruction;        
        public wrapper(Required_Documents__c rd){
            rd = new Required_Documents__c();
            rd= reqdoc;
        }
    }
    
}