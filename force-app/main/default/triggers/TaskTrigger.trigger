/*
* @Created By   : Vishal Singh 
* @Created Date : 26-08-2024
* @Description  : Need to write the trigger for send a notification when a task is completed
Last modified by: Sougata Paul; Last Modified on: 03-09-2024; Des: Need to capture the user who has completed the Task
*/
trigger TaskTrigger on Task (Before Insert ,before update,  After Insert, After Update,after Delete, after Undelete) {
    if(trigger.IsBefore && Trigger.isupdate){
        // List to hold the tasks that have been completed
        List<Task> completedTasks = new List<Task>();
        // Collect the IDs of the tasks to query the Owner's details
        Set<Id> taskIds = new Set<Id>();
        for (Task t : Trigger.new) {
            taskIds.add(t.Id);
        }
        
        // Query the Owner details for the tasks in this trigger
        Map<Id, Task> taskMap = new Map<Id, Task>([SELECT Id, Owner.Name FROM Task WHERE Id IN :taskIds]);
        
        // Loop through the tasks and check if the status was updated to "Completed"
        for (Task t : Trigger.new) {
            Task oldTask = Trigger.oldMap.get(t.Id);
            Task queriedTask = taskMap.get(t.Id); // Get the task with Owner details
            System.debug(queriedTask.Owner.Name);
            if (t.Status == 'Completed' && oldTask.Status != 'Completed' ) {
                completedTasks.add(t); //&& queriedTask.Owner.Name == 'Operation Queue'
            }
        }
        
        // If there are any completed tasks, call the method to send notifications
        if (completedTasks.size() > 0) {
            TaskTriggerHandler.sendCompletionNotification(completedTasks);
        }
    }
    
    if(trigger.isAfter){
       // if(trigger.isInsert){
       //     system.debug('inside after insert');
           // tastTeiggerHandlerAdi.trigger1(trigger.new);
      //     tastTeiggerHandlerAdi.Update_TaskDetails(trigger.new);
     //   }
        if(trigger.isInsert){
            system.debug('inside after INSERT');
            tastTeiggerHandlerAdi.trigger1(trigger.new);
            tastTeiggerHandlerAdi.Update_TaskDetails(trigger.new);
        }
         if(trigger.isUpdate){
            system.debug('inside after isUpdate');
            tastTeiggerHandlerAdi.Update_TaskDetailsOnStatus(trigger.new,trigger.OldMAp);
        }
    }
}