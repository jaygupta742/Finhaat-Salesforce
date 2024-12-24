trigger taskTriggerFollow on Task (before insert) {

    if(trigger.isBefore ){
        if(trigger.isInsert){
        tasktriggerHandlerFollowUp.trigger12(trigger.new);     
        }
       
    }
}