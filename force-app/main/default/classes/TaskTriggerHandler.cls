/*
   @Created By   : Vishal Singh 
   @Created Date : 26-08-202
   @Last Modified by    : vishal singh 
   @Last MOdified Date  : 28-08-2024
   @Description         1.Need to modifined the body Like: Task : [subject]
 */
public class TaskTriggerHandler {
	// New method to send a notification when a task is completed
    public static void sendCompletionNotification(List<Task> completedTasks) {
        // Prepare the list for notifications
        List<Messaging.CustomNotification> notifications = new List<Messaging.CustomNotification>();
        
        // Define the custom notification type
        CustomNotificationType cnType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'sendCustomNotification' LIMIT 1];
        system.debug('CustomNotificationType--->'+cnType);

        for (Task t : completedTasks) {
            // Query the related Ticket__c record
            Ticket__c relatedTicket = [SELECT Id,Name, OwnerId FROM Ticket__c WHERE Id = :t.WhatId LIMIT 1];
             
            
            // Query current user details
            User currentUser = [SELECT Id, Name, Email FROM User WHERE Id = : UserInfo.getUserId()];
            system.debug('Get Current User Name--->'+currentUser.Name);
            
            t.Task_Completed_By__c = currentUser.Id;
            
            String title = '';
            title =currentUser.Name+ ' has completed the task you assigned !!';
       String relatedTicketName = relatedTicket.Name;
String body = relatedTicketName + '\nDo have a look at this ticket and do the necessary actions.';


            // Create a custom notification for the Ticket__c owner
            Messaging.CustomNotification customNotificationObj = new Messaging.CustomNotification();
            customNotificationObj.setTitle(title);
            customNotificationObj.setBody(body);
            customNotificationObj.setNotificationTypeId(cnType.Id);
            customNotificationObj.setSenderId(UserInfo.getUserId());
            customNotificationObj.setTargetId(relatedTicket.Id);
            customNotificationObj.send(new Set<String> {T.CreatedById});
            system.debug('Notification Send'+customNotificationObj);
        }
    }
}