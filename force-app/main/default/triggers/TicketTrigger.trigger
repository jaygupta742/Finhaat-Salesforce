trigger TicketTrigger on Ticket__c (before update,after insert, after update) {
    if(trigger.isBefore &&  trigger.isUpdate){
        TicketTrigger_helper.update_method(trigger.new, Trigger.oldMap);
    }
    if(trigger.isafter && trigger.isinsert){
        TicketNotificationForAccount.getNotification(trigger.new, null);
    }
    if(trigger.isafter && trigger.isupdate){
          TicketNotificationForAccount.getNotification(trigger.new, trigger.oldMap);
    }
    
     // This below block of code is written by vishal singh on 12-12-2024...
    if (Trigger.isAfter && Trigger.isUpdate) {
        sendEmailImmediateEscalation.sendEmailOnEscalation(Trigger.new, Trigger.oldMap);
    }
}