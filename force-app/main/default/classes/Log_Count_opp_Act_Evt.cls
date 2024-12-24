/*Created Date : 18/04/2024 by Vijay Somvanshi*/
public class Log_Count_opp_Act_Evt {
    public static void logmethodTask(List<Task> tasklist){
        Set<Id> oppid = new Set<Id>();
        List<Opportunity> opplist = new List<Opportunity>();
        for(Task ta : tasklist){
            oppid.add(ta.WhatId);
        }
        for(Opportunity opp : [select id,(select id,WhatId from Tasks ), (select id, WhatId from Events) from Opportunity WHERE id IN : oppid]){
            Integer callCount = 0; // Initializing the call count
            for(Task task : opp.Tasks){
                callCount++; // Incrementing the call count for each task with subject 'Call'
            }
            for(Event event : opp.Events){
                callCount++; // Incrementing the call count for each task with subject 'Call'
            }
            opp.Log_Count__c = callCount; // Assigning the call count to the custom field
            opplist.add(opp);
        }
        update opplist;
    }
    public static void logmethodEvent(List<Event> Eventlist){
        Set<Id> oppid = new Set<Id>();
        List<Opportunity> opplist = new List<Opportunity>();
        for(Event ev : Eventlist){
            oppid.add(ev.WhatId);
        }
        for(Opportunity opp :[select id,(select id,WhatId from Tasks ), (select id, WhatId from Events) from Opportunity WHERE ID IN : oppid]){
            
            Integer callCount = 0; // Initializing the call count
            for(Task task : opp.Tasks){
                callCount++; // Incrementing the call count for each task with subject 'Call'
            }
            for(Event event : opp.Events){
                callCount++; // Incrementing the call count for each task with subject 'Call'
            }
            opp.Log_Count__c = callCount; // Assigning the call count to the custom field
            opplist.add(opp);
        }
        update opplist;
    }
}