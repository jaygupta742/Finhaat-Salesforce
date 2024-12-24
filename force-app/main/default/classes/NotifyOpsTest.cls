/*
* @Created By   : Vishal Singh 
* @Created Date : 26-08-2024
* @Description  : Need to write the test class for the apex class Named "NotifyOps"
*/
@IsTest
public class NotifyOpsTest {
     
    @TestSetup
    static void setup() {
        /*
        // First, create the Group (Queue) inside a system context
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(adminUser) {
            Group queue = new Group();
            queue.Name = 'Operation Queue';
            queue.Type = 'Queue';
            insert queue;

            // Associate the Queue with the Ticket__c object in QueueSObject
            QueueSObject queueSobj = new QueueSObject();
            queueSobj.QueueId = queue.Id;
            queueSobj.SObjectType = 'Task';
            insert queueSobj;
        }*/
        // Create a Ticket record
        Ticket__c ticket = new Ticket__c();
        ticket.Stage__c = 'Ticket Raised';
        insert ticket;
    }
    
    @IsTest
    static void testSaveAccountDetails() {
        // Get the QueueSobject
        QueueSobject queueSobj = [SELECT Id, QueueId, SobjectType FROM QueueSobject WHERE SobjectType = 'Ticket__c' LIMIT 1];
        
        // Create a JSON string that mimics the taskDetails parameter
        String taskDetails = '{"Subject":"Test Task","Comments":"This is a test task","Priority":"High","DueDate":"2024-08-30"}';
        String recordId = [SELECT Id FROM Ticket__c LIMIT 1].Id;
        
        // Call the method
        Test.startTest();
        String result = NotifyOps.saveAccountDetails(taskDetails, recordId, '');
        Test.stopTest();
    }
    
    @IsTest
    static void testSaveAccountDetailsWithException() {
        // Pass an invalid JSON string to force an exception
        String taskDetails = 'Invalid JSON String';
        String recordId = [SELECT Id FROM Ticket__c LIMIT 1].Id;
        
        Test.startTest();
        try {
            NotifyOps.saveAccountDetails(taskDetails, recordId, '');
        } catch (AuraHandledException e) {
            
        }
        Test.stopTest();
    }
    /*
    @IsTest
    static void testTaskCompletionNotification() {
        // Get the Queue created in @TestSetup
        Group queue = [SELECT Id, Name FROM Group WHERE Name = 'Operation Queue' LIMIT 1];
        System.debug(queue.Name);
        // Create a Task and assign it to the queue
        Task task = new Task(
            Subject = 'Test Task',
            WhatId = [SELECT Id FROM Ticket__c LIMIT 1].Id,
            Status = 'Not Started',
            OwnerId = queue.Id // Assign to the queue
        );
        insert task;

        // Update the Task status to "Completed" and trigger the notification logic
        Test.startTest();
        task.Status = 'Completed';
        update task;
        Test.stopTest();
    }
*/
}