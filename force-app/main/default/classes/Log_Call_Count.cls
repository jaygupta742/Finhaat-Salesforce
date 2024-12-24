public class Log_Call_Count {
    public static void logcallmethod(List<Task> tasklist){
        Set<Id> accid = new Set<Id>();
        List<Account> acclist = new List<Account>();
        for(Task ta : tasklist){
           // system.debug('ta'+ta.CallType);
           // system.debug('task'+ta);
            if(ta.TaskSubtype =='Call' ){
                 accid.add(ta.WhatId);
            }
           
        }
        for(Account acc :[select id,(select id,WhatId from Tasks WHERE TaskSubtype='Call' ) from Account WHERE ID IN : accid]){
          /* acc.Log_call_Count__c = acc.Tasks.Size();
            acclist.add(acc);*/
             Integer callCount = 0; // Initializing the call count
            for(Task task : acc.Tasks){
                callCount++; // Incrementing the call count for each task with subject 'Call'
            }
            acc.Log_call_Count__c = callCount; // Assigning the call count to the custom field
            acclist.add(acc);
        }
       update acclist;
        
    }
    
}