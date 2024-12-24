/* Created By : Vijay Somvanshi 
Created Date : 18/04/2024*/
@istest
public class Log_count_Act_Evt_Test {
    public static testmethod void tesData(){
        Account acc = new Account(Name = 'test');
        insert acc;
        List<Task> testTasks = new List<Task>();
        for(Integer i = 0; i < 3; i++) {
            testTasks.add(new Task(Subject = 'call' + i , WhatId = acc.Id));
        }
        List<Event> eventlist = new List<Event>();
        for(Integer i = 0; i < 3; i++) {
            eventlist.add(new Event(Subject = 'call' + i , WhatId = acc.Id, DurationInMinutes = 10, ActivityDate = system.today(), StartDateTime = system.today()));
        }
        Test.startTest();
        insert testTasks;
        insert eventlist;
        Log_count_Act_Evt.logmethodTask(testTasks);
        Log_count_Act_Evt.logmethodEvent(eventlist);
        Test.stopTest();
        acc = [SELECT Id, Log_Count__c FROM Account WHERE Id = :acc.Id];
        List<Task> taskList = [select id from Task];
        Update taskList;
        
        List<Event> eventList2 = [select id from Event];
        Update eventList2;
        // Assert that the Log_Call_Count__c field is updated correctly
        System.assertEquals(6, acc.Log_Count__c, 'Log Call Count is incorrect');
    }
    public static testmethod void opptestdata(){
         Account acc = new Account(Name = 'test');
        insert acc;
        Opportunity opp = new Opportunity();
        opp.Name = 'testing';
        opp.CloseDate = system.today();
        opp.StageName = 'Discovery';
        opp.AccountId = acc.id;
        insert opp;
        List<Task> tasklist = new List<Task>();
        for(Integer i = 0; i<3; i++){
            tasklist.add(new task(Subject = 'call' + i , WhatId = opp.Id));
        }
       List<Event> eventlist = new List<Event>();
        for(Integer i = 0; i<3; i++){
            eventlist.add(new Event(Subject = 'call' + i , WhatId = opp.Id, DurationInMinutes = 10, ActivityDate = system.today(), StartDateTime = system.today()));
        }
         insert tasklist;
        insert eventlist;
        Test.startTest();
       
        Log_Count_opp_Act_Evt.logmethodTask(tasklist);
        Log_Count_opp_Act_Evt.logmethodEvent(eventlist);
        Test.stopTest();
         opp = [SELECT Id, Log_Count__c FROM Opportunity WHERE Id = :opp.Id];
         update opp; 
          System.assertEquals(6, opp.Log_Count__c, 'Log Call Count is incorrect');
       
    }
}