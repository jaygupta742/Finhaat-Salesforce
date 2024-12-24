public class tastTeiggerHandlerAdi {
    
    public static void trigger1(List<Task> newList1) {
        Set<Id> userId = new Set<Id>();
        String userNumber;
        task newtask1;
        string taskSub;
        List<Task> newList=   [SELECT Id, Owner.Name,Subject,OwnerId,whatId , Status FROM Task WHERE Id IN :newList1];
        for (Task newTask : newList) {
            system.debug('Operation Queue on insert'+newTask.Owner.Name);
            if (newTask.OwnerId != null && newTask.Owner.Name == 'Operation Queue') { 
                newtask1 = newTask;
                taskSub = newTask.subject;
                userId.add(newTask.OwnerId);
            }
        }
        string task_name;
        try{
            Ticket__c tkt=[Select id , Name from Ticket__c where id=:newtask1.WhatId Limit 1];
            task_name=tkt.Name;
        }
        catch(exception e){
            system.debug('Ticket Not Found ');
        }
        System.debug(userId);
        if(userId.contains(system.label.Operation_Queue)){
            QueueSobject queueSobj = [SELECT Id, QueueId, SobjectType FROM QueueSobject where SobjectType = 'Ticket__c' LIMIT 1];
            List<User> userList = [SELECT Id, FirstName, LastName, Phone FROM User WHERE Id IN(SELECT UserOrGroupId FROM GroupMember WHERE GroupId =: queueSobj.QueueId)];
            for (User u : userList) {
                //systwm.debug
                userNumber = u.Phone;
                // Send WhatsApp message
                //   sendWhatsAppMessage(userNumber, u.LastName+' A new task has been assigned to you. '+taskSub+' Please review the details and take the necessary actions.');
                // Send Custom Notification
                sendCustomNotification(u.Id, newtask1,task_name);
                /*   string uLName;
uLName = u.LastName;
Messaging.CustomNotification notification = new Messaging.CustomNotification();
notification.setTitle('New Task Assign');
notification.setBody('A new task has been assigned to you by. '+uLName+'. Here is Task : '+newtask1.Subject+'. Please review the details and take the necessary actions.');
notification.setTargetId(newtask1.Id); 
notification.setNotificationTypeId(getNotificationTypeId('sendCustomNotification'));
notification.setSenderId(userinfo.getUserId());
notification.send(new Set<String> {u.Id});*/
            }
            
            System.debug(userList);
            System.debug(userNumber);
        }
    }
    
    /* @future(callout=true)
public static void sendWhatsAppMessage(String toPhoneNumber, String messageBody) {
String apiEndpoint = System.Label.Whatsera_Send_Sms_EndPoint + '/api/send/text';

HttpRequest req = new HttpRequest();
req.setEndpoint(apiEndpoint);
req.setMethod('POST');
req.setHeader('Content-Type', 'Application/json');

// Construct the JSON body of the request
Map<String, Object> payload = new Map<String, Object>();
payload.put('mobile', toPhoneNumber);
payload.put('text', messageBody);
payload.put('accessToken', '6614dfacc843dde3f1cd9e2e'); // Replace with actual accessToken
String requestBody = JSON.serialize(payload);
req.setBody(requestBody);

try {
Http http = new Http();
HttpResponse res = http.send(req);
if (res.getStatusCode() == 200) {
System.debug('Request URL: ' + apiEndpoint);
System.debug('Request Body: ' + requestBody);
System.debug('Response Status Code: ' + res.getStatusCode());
System.debug('Response Body: ' + res.getBody());
} else {
System.debug('Failed to send WhatsApp message to ' + toPhoneNumber + ': ' + res.getBody());
}
} catch (Exception e) {
System.debug('Exception while sending WhatsApp message: ' + e.getMessage());
}
}*/
    
    // Method to send custom notification
    public static void sendCustomNotification(Id ownerId, Task newTask , String task_name) {
        try {
            List<User> userList = [SELECT Id, FirstName, LastName, Phone FROM User WHERE Id = :ownerId];
            
            for(user u : userList){
                string uLName;
                uLName = u.LastName;
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setTitle((task_name==null)?'New task raised !!':task_name+' | New task raised !!');
                notification.setBody('Current Status: ' + newTask.Status + '\n' + 'Assigned By: ' + UserInfo.getName() + '\n' +'Please review the details and take the necessary actions.');    
                notification.setTargetId(newTask.WhatId); 
                notification.setNotificationTypeId(getNotificationTypeId('sendCustomNotification'));
                notification.setSenderId(userinfo.getUserId());
                notification.send(new Set<String> { ownerId});
                
            }
            
        } catch (Exception e) {
            System.debug('Error sending custom notification: ' + e.getMessage());
        }
    } 
    
    
    private static Id getNotificationTypeId(String developerName) {
        CustomNotificationType notificationType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = :developerName LIMIT 1];
        return notificationType.Id;
    }
    
    // This method using to Update task Subject & Comment & status is Ticket 
    public static void Update_TaskDetails(List<task>  task_list){
        set<id> ids=New Set<id>();
        for(Task  t:task_list){
            if(t.whatid != null){
                ids.add(t.WhatId);
            } 
        }
        
        list<Ticket__c>  objlist=[select id  ,Last_Task_Comment__c,Last_Task_Status__c,Last_Task_Subject__c,Last_Task_Assigned_To__c,Last_Task_Completed_Date_Time__c,Last_Task_Created_By__c,
                                  (Select id,Subject,Status,Description,OwnerId, CreatedbyId,CompletedDateTime,Owner.Name from Tasks order by Createddate desc limit 1) from Ticket__c where id In : Ids];
        system.debug('objlist '+objlist.Size());
        if(objlist.Size()>0){
            for(Ticket__c tk:objlist){
                string sub , com, status, OwnerId,CreatedbyId;
                datetime CompletedDateTime;
                sub=com= status=CreatedbyId='';
                system.debug('inside task list check  '+tk.tasks.Size());
                if(tk.tasks.size()>0){
                    for(Task t:tk.Tasks){
                        system.debug('t.Subject '+t.Subject+' t.Status '+t.Status+',  t.Description');
                        sub=t.Subject;
                        status=t.Status;
                        com = t.Description;
                        system.debug(' Check operation queue name '+t.Owner.Name );
                        OwnerId = t.Owner.Name;
                        CreatedbyId= t.CreatedById;
                        CompletedDateTime = t.CompletedDateTime;
                    }  
                }
                tk.Last_Task_Comment__c = com;
                tk.Last_Task_Status__c = status;
                tk.Last_Task_Subject__c = sub;
                tk.Last_Task_Created_By__c = CreatedbyId;
                tk.Last_Task_Assigned_To__c = OwnerId;
                tk.Last_Task_Completed_Date_Time__c = CompletedDateTime;
            } 
            Update objlist;
        }
    } 
    
    public static void Update_TaskDetailsOnStatus(List<task>  task_list, Map<id, Task> taskids){
        set<id> ids=New Set<id>();
        for(Task  t:task_list){
            task oldt = taskids.get(t.Id);
            if(t.whatid != null && t.Status =='Completed' && t.Status != oldt.Status && T.CompletedDateTime != NULL){
                ids.add(t.WhatId);
            } 
        }
        
        list<Ticket__c>  objlist=[select id  ,Last_Task_Comment__c,Last_Task_Status__c,Last_Task_Subject__c,Last_Task_Assigned_To__c,Last_Task_Completed_Date_Time__c,Last_Task_Created_By__c,
                                  
                                  (Select id,Subject,Status,Description,OwnerId, CreatedbyId,CompletedDateTime,owner.Name from Tasks order by CompletedDateTime desc limit 1) from Ticket__c where id In : Ids];
        system.debug('objlist '+objlist.Size());
        if(objlist.Size()>0){
            for(Ticket__c tk:objlist){
                string sub , com, status, OwnerId,CreatedbyId;
                datetime CompletedDateTime;
                sub=com= status=OwnerId=CreatedbyId='';
                system.debug('inside task list check  '+tk.tasks.Size());
                if(tk.tasks.size()>0){
                    for(Task t:tk.Tasks){
                        system.debug('t.Subject '+t.Subject+' t.Status '+t.Status+',  t.Description' +' CompletedDateTime '+t.CompletedDateTime);
                        sub=t.Subject;
                        status=t.Status;
                        com = t.Description;
                        OwnerId = userinfo.getName();
                        CreatedbyId= t.CreatedById;
                        CompletedDateTime = t.CompletedDateTime;
                    }  
                }
                tk.Last_Task_Comment__c = com;
                tk.Last_Task_Status__c = status;
                tk.Last_Task_Subject__c = sub;
                tk.Last_Task_Created_By__c = CreatedbyId;
                tk.Last_Task_Assigned_To__c = OwnerId;
                tk.Last_Task_Completed_Date_Time__c = CompletedDateTime;
                
            } 
            SYSTEM.DEBUG(objlist[0].Last_Task_Completed_Date_Time__c);
            Update objlist;
        }
    }  
}