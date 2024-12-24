@isTest
public class Log_Call_Count_Test {
    @isTest
    static void testLogCallMethod() {
        // Create test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Create test Tasks related to the test Account
        List<Task> testTasks = new List<Task>();
        for(Integer i = 0; i < 3; i++) {
            testTasks.add(new Task(Subject = 'call' + i,TaskSubtype='Call' , WhatId = testAccount.Id));
        }
     
        
        // Call the logCallMethod and check if Log_call_Count__c is updated correctly
        Test.startTest();
           insert testTasks;
        Log_Call_Count.logcallmethod(testTasks);
        Test.stopTest();
        
        // Retrieve the updated Account record
        testAccount = [SELECT Id, Log_Call_Count__c FROM Account WHERE Id = :testAccount.Id];
        
        // Assert that the Log_Call_Count__c field is updated correctly
        System.assertEquals(3, testAccount.Log_Call_Count__c, 'Log Call Count is incorrect');
    }
}