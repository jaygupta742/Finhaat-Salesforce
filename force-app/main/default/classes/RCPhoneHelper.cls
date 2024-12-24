global with sharing class RCPhoneHelper {

    // Inbound Screen Pop
    webService static Contact searchContact(String phone) {
        
        try{
            
             Contact contact = [SELECT Id, Name FROM Contact WHERE Phone = :phone WITH SECURITY_ENFORCED LIMIT 1];
    
              if (contact.Id != null) {
                   return contact; // A matching contact was found
              }
    
             return null; // No matching contact was found
            
        }catch(System.QueryException e){
            return null;
        }
    }
    
    
    // Call Logging
    webService static void logACall(string contactId, Integer duration, String fromNumber, String toNumber, String callStatus, String clientName) {
    
        if (Task.SObjectType.getDescribe().isAccessible() && Task.SObjectType.getDescribe().isCreateable()) {

            if(!Schema.SObjectType.Task.fields.WhoId.isCreateable()){
                throw new System.SecurityException('Insufficient permissions to log the call.');
            }

            if(!Schema.SObjectType.Task.fields.ActivityDate.isCreateable()){
                throw new System.SecurityException('Insufficient permissions to log the call.');
            }
    
            if(!Schema.SObjectType.Task.fields.CallDurationInSeconds.isCreateable()){
                throw new System.SecurityException('Insufficient permissions to log the call.');
            }
    
            if(!Schema.SObjectType.Task.fields.CallType.isCreateable()){
                throw new System.SecurityException('Insufficient permissions to log the call.');
            }
    
            if(!Schema.SObjectType.Task.fields.Description.isCreateable()){
                throw new System.SecurityException('Insufficient permissions to log the call.');
            }

            if(!Schema.SObjectType.Task.fields.Status.isCreateable()){
                throw new System.SecurityException('Insufficient permissions to log the call.');
            }
    
            if(!Schema.SObjectType.Task.fields.Subject.isCreateable()){
                throw new System.SecurityException('Insufficient permissions to log the call.');
            }

            if(!Schema.SObjectType.Task.fields.TaskSubtype.isCreateable()){
                throw new System.SecurityException('Insufficient permissions to log the call.');
            }
    
            


            String InDescription = 'From: ' + fromNumber + '\nTo: ' + toNumber + '\nDuration: ' + duration + ' seconds';
            String InSubject = 'Outbound Call to ' + clientName;

            
    
            Task t = new Task(
                ActivityDate = date.today(),
                CallDurationInSeconds = duration,
                CallType = 'Outbound',
                Description = InDescription,
                Status = callStatus,
                Subject = InSubject,
                TaskSubtype = 'Call',
                WhoId = contactId
            );
    
            insert t;
        } else {
            // Handle scenarios where CRUD checks fail. 
            // You can use custom exceptions or a general one like:
            throw new System.SecurityException('Insufficient permissions to log the call.');
        }
    }
    
    
    
     // Add Contact
    webService static Contact addContact( String phone) {
        
        
        
        if(Contact.SObjectType.getDescribe().isAccessible() && 
       Contact.SObjectType.getDescribe().isCreateable() && 
       Schema.SObjectType.Contact.fields.LastName.isCreateable() && 
       Schema.SObjectType.Contact.fields.Phone.isCreateable()) {
       
       Contact newContact = new Contact(LastName = 'Unknown', Phone = phone);
       insert newContact;
       return newContact;
    }
        
        return null;
      
    }
    
     // Call Logging
    webService static void logInCall(string contactId, Integer duration, String fromNumber, String toNumber,String callStatus,String clientName) {


        if (Task.SObjectType.getDescribe().isAccessible() && Task.SObjectType.getDescribe().isCreateable()) {



            if(!Schema.SObjectType.Task.fields.WhoId.isCreateable()){
                throw new System.SecurityException('Insufficient permissions to log the call.');
            }

            if(!Schema.SObjectType.Task.fields.ActivityDate.isCreateable()){
                throw new System.SecurityException('Insufficient permissions to log the call.');
            }
    
            if(!Schema.SObjectType.Task.fields.CallDurationInSeconds.isCreateable()){
                throw new System.SecurityException('Insufficient permissions to log the call.');
            }
    
            if(!Schema.SObjectType.Task.fields.CallType.isCreateable()){
                throw new System.SecurityException('Insufficient permissions to log the call.');
            }
    
            if(!Schema.SObjectType.Task.fields.Description.isCreateable()){
                throw new System.SecurityException('Insufficient permissions to log the call.');
            }

            if(!Schema.SObjectType.Task.fields.Status.isCreateable()){
                throw new System.SecurityException('Insufficient permissions to log the call.');
            }
    
            if(!Schema.SObjectType.Task.fields.Subject.isCreateable()){
                throw new System.SecurityException('Insufficient permissions to log the call.');
            }

            if(!Schema.SObjectType.Task.fields.TaskSubtype.isCreateable()){
                throw new System.SecurityException('Insufficient permissions to log the call.');
            }
    
          

        String description = 'From: ' + fromNumber + '\nTo: ' + toNumber + '\nDuration: ' + duration + ' seconds';
        String subject = 'Incoming Call from '+clientName;

        Task t = new Task(
            ActivityDate = date.today(),
            CallDurationInSeconds = duration,
            CallType = 'Inbound',
            Description = description,
            Status = callStatus,
            Subject = subject,
            TaskSubtype = 'Call',
            WhoId = contactId
        );
        insert t;
        }else {
            throw new System.SecurityException('Insufficient permissions to log the call.');
        }
    }
}