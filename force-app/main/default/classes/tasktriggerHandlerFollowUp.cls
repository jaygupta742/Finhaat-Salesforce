/*
Created by : Aditya Yede
Created Date : 10/04/2024
Description : Create a fields on Account log call activity
*/
    public class tasktriggerHandlerFollowUp {
    public static void trigger12(list<task> newList){
        list<task> newTaskList = new list<task>();
        for(task tt : newList){
            if(tt.Follow_Up_Needed__c == true && (tt.Follow_Up_Due_Date__c == null || tt.Follow_Up_Subject__c == null)){
                tt.addError('Please enter the follow up date and subject.');
            }else{ 
                if(tt.Follow_Up_Due_Date__c < system.today()){
                    tt.addError('Follow due date cannot be past, Please select today or future date.');
                }
                if(tt.Follow_Up_Reminder_Date_Time__c < system.today()){
                    tt.addError('Follow up reminder date can not be past, Please select today or future date.');
                }
               
                if(tt.Follow_Up_Needed__c == true){
                    Task newTask = new Task();
                    newTask.ActivityDate = tt.Follow_Up_Due_Date__c;
                    newTask.Subject = tt.Follow_Up_Subject__c;
                    newTask.WhatId = tt.WhatId;
                    newTask.Priority = tt.Priority__c;
                    newTAsk.OwnerId = UserInfo.getUserId(); 
                    newTask.IsReminderSet = true;
                    newTask.ReminderDateTime = tt.Follow_Up_Reminder_Date_Time__c;
                    if(tt.WhatId != null && tt.WhatId.getSobjectType() == Account.SobjectType){
                        Account acc = [select id, ownerId From Account where id =: tt.WhatId Limit 1];
                        newTask.OwnerId = acc.OwnerId;
                    }
                     if(tt.WhatId != null && tt.WhatId.getSobjectType() == opportunity.SobjectType){
                        opportunity acc = [select id, ownerId From opportunity where id =: tt.WhatId Limit 1];
                        newTask.OwnerId = acc.OwnerId;
                    }
                    if(tt.WhatId != null && tt.WhatId.getSobjectType() == Contact.SobjectType){
                        Contact acc = [select id, ownerId From Contact where id =: tt.WhatId Limit 1];
                        newTask.OwnerId = acc.OwnerId;
                    }
                    
                    
                    newTaskList.add(newTask);
                    system.debug(newTask.OwnerId+'owner id'); 
                    system.debug(UserInfo.getUserId()+'user id'); 
              
                }   
            }
           
        }
        if(!newTaskList.isEmpty()){
            insert newTaskList;
        }
    }
    
}