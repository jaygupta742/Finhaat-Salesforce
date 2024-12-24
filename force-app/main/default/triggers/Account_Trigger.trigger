trigger Account_Trigger on Account (before insert, Before Update, After Insert, After Update) {
    
        if(trigger.isBefore && trigger.isInsert){
            Account_Duplicate_Name.insert_Name(trigger.new);
        }
        if(trigger.IsAfter && Trigger.IsInsert){
            Account_Duplicate_Name.insert_requiredDoc(trigger.new);        
            Account_Duplicate_Name.sendWhatsappWelcomeMessage(JSON.serialize(trigger.new));
        }
        
        if(trigger.IsBefore && trigger.IsUpdate){
            Account_Duplicate_Name.checkdocstatus(trigger.new, Trigger.Oldmap); 
        }
    
    
    //this method is created by vishal singh when account account stage is changed... 
    if(trigger.IsAfter && Trigger.IsUpdate){
        // Create a list to hold accounts where the Stage__c field has changed
        List<Account> accountsToNotify = new List<Account>();
        
        for (Account acc : Trigger.new) {
            // Compare the new Stage__c value with the old one
            if (acc.Stage__c != Trigger.oldMap.get(acc.Id).Stage__c) {
                accountsToNotify.add(acc);
            }
        }
        
        // Call the handler method to send WhatsApp messages for the relevant accounts
        // this method is added by vishal singh on 05-10-2024
        if (accountsToNotify.size() > 0) {
            Account_Trigger_Handler.sendWhatsMessageWhenAccountStagechange(JSON.serialize(accountsToNotify));
        }
        
    }
}