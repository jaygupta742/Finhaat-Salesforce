global class BatchUpdateTask implements Database.Batchable<sObject>{
    List<Task> taskToUpdate; 
    global BatchUpdateTask(List<Task> Task) {
        taskToUpdate = Task;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
		String query ='select id,WhatId  from Task where id IN: taskToUpdate';   
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Task> taskList) {
        
        if (taskList != null && taskList.size() > 0) {
            update taskList;
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        System.debug(taskToUpdate.size());
    }
}