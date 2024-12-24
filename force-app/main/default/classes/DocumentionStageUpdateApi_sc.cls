public class DocumentionStageUpdateApi_sc Implements Schedulable {
    Public void Execute(SchedulableContext  sc){
        List <Opportunity> opplist=[Select Id From Opportunity Where StageName=:'Quote Accepted' or (StageName=:'Discovery' and Mandate_Signed__c =: false) ];
        system.debug('Schedulabe inside oppList '+opplist.Size());
        Set<id> ids=New Set<id>();
        for(Opportunity op:opplist){            ids.add(op.id);        }
        if(opplist.Size()>0){ Database.ExecuteBatch(New DocumentionStageUpdateApi_scBatch(ids),1); }  
        
    }

}