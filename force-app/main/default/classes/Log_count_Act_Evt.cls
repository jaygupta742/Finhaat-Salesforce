/* Created By : Vijay Somvanshi 
Created Date : 18/04/2024*/
public class Log_count_Act_Evt {
    public static void logmethodTask(List<Task> tasklist){
        Set<Id> accid = new Set<Id>();
        List<Account> acclist = new List<Account>();
        for(Task ta : tasklist){
            accid.add(ta.WhatId);
        }
        
        for(Account acc :[select id,(select id,WhatId from Tasks ), (select id, WhatId from Events) from Account WHERE ID IN : accid]){
            
            Integer callCount = 0; // Initializing the call count
            for(Task task : acc.Tasks){
                callCount++; // Incrementing the call count for each task with subject 'Call'
            }
            for(Event event : acc.Events){
                callCount++; // Incrementing the call count for each task with subject 'Call'
            }
            acc.Log_Count__c = callCount; // Assigning the call count to the custom field
            acclist.add(acc);
        }
        update acclist;
    }
    public static void logmethodEvent(List<Event> Eventlist){
        Set<Id> accid = new Set<Id>();
        List<Account> acclist = new List<Account>();
        for(Event ev : Eventlist){
            accid.add(ev.WhatId);
        }
        for(Account acc :[select id,(select id,WhatId from Tasks ), (select id, WhatId from Events) from Account WHERE ID IN : accid]){
            
            Integer callCount = 0; // Initializing the call count
            for(Task task : acc.Tasks){
                callCount++; // Incrementing the call count for each task with subject 'Call'
            }
            for(Event event : acc.Events){
                callCount++; // Incrementing the call count for each task with subject 'Call'
            }
            acc.Log_Count__c = callCount; // Assigning the call count to the custom field
            acclist.add(acc);
        }
        update acclist;
    }
}