/*
* @Created By   : Vishal Singh 
* @Created Date : 26-08-2024
* @Description  : Need to create Task from the component  Under the Ticket object Named "Notify Ops"  And need to send the custom bell icon notification to Queue user
* 				 : I also write a  New method to send a notification when a task is completed
* 
* Last modified by : vishal sing 
* date             : 28-08-2024
* Description      : title should be like Title: account Name - Tickect number  and Body : - subject 
* 
* Last Modified by Shreyash urkude on 04/09/2024. Description : Added Queue Option.
*/ 
public class NotifyOps {
    
    @AuraEnabled(cacheable=true)
    public static List<Group> getCustomObjectOptions() {        
        return [SELECT Id, Name FROM Group WHERE Type = 'Queue'];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<User> getUsers() {        
        return [SELECT Id, Name FROM User where Profile.Name = 'POS Ops' AND IsActive = true];
    }
    
    @AuraEnabled
    public static string saveAccountDetails(String taskDetails, string recordId, String queueId) {
        try {
            String title = ''; 
            Ticket__c relatedTicket = [SELECT Id,Name, Account__r.Name FROM Ticket__c WHERE Id = :recordId LIMIT 1];
            if(relatedTicket.Account__r.Name != null){
                title = relatedTicket.Account__r.Name + ' - ' + relatedTicket.Name;
            }
            QueueSobject queueSobj = [SELECT Id, QueueId, SobjectType FROM QueueSobject where SobjectType = 'Ticket__c' LIMIT 1];
            Map<String, Object> taskDataMap = (Map<String, Object>) JSON.deserializeUntyped(taskDetails);
            
            Task newTask = new Task();
            List<Task> tasksToInsert = new List<Task> ();
            newTask.Subject = (String) taskDataMap.get('Subject'); 
            newTask.Description = (String) taskDataMap.get('Comments');
            newTask.Priority = (String) taskDataMap.get('Priority');
            newTask.ActivityDate = Date.valueOf((String) taskDataMap.get('DueDate'));
            newTask.WhatId = recordId;
            newTask.Status = 'Not Started';
            newTask.ReminderDateTime = System.now().addHours(3); 
            newTask.IsReminderSet = true; 
            system.debug('Queue >> ' + queueId);
            if (String.isNotBlank(queueId)) {
                newTask.OwnerId = queueId;
            } else {
                newTask.OwnerId = queueSobj.QueueId;
            }
            
            // Add the Task to the list
            tasksToInsert.add(newTask);
            
            // Insert all the tasks in one DML operation
            insert tasksToInsert;
            
            // Define the custom notification type
            CustomNotificationType cnType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'sendCustomNotification'];
            
            // Query the users in the queue using the GroupMember object
            //List<GroupMember> groupMembers = [
            // SELECT UserOrGroupId 
            // FROM GroupMember 
            // WHERE GroupId = :queueSobj.QueueId
            // ];
            
            List<User> users = [
                SELECT Id, Name, Email 
                FROM User 
                WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :queueSobj.QueueId)
            ];
            
            for (User u : users) {
                Messaging.CustomNotification customNotificationObj = new Messaging.CustomNotification();
                customNotificationObj.setTitle(title);
                customNotificationObj.setBody((String) taskDataMap.get('Subject'));
                customNotificationObj.setNotificationTypeId(cnType.id);
                customNotificationObj.setSenderId(UserInfo.getUserId());
                customNotificationObj.setTargetId(recordId);
              //  customNotificationObj.send(new Set<String> {u.Id});
            }
            return recordId;
        } catch (Exception e) {
            System.debug('Error message: ' + e.getMessage());
            System.debug('Error line number: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
}