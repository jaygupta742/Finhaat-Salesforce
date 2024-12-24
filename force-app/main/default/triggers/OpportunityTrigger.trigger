//Created by Ashish Kurzekar on 9.5.24;
trigger OpportunityTrigger on Opportunity (before insert,before update){
    if(trigger.isBefore && trigger.isUpdate){
        OpportunityTriggerHandler.ValidateOpportunityStage(trigger.new, trigger.oldMap);
    }
}