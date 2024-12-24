//Created by Ashish Kurzekar on 9.5.24;
public class OpportunityTriggerHandler {
    Public static void ValidateOpportunityStage(List<Opportunity> newList, Map<Id,Opportunity> oldMap){
        
        if(!newList.isEmpty() && !oldMap.isEmpty()){
            for(Opportunity o : newList){
                if(o.StageName != oldMap.get(o.Id).StageName){
                    if(o.StageName == 'Policy Created' && oldMap.get(o.Id).StageName != 'Training'){o.addError(system.label.Stage_to_Policy_Created);break;
                        //o.addError('To Change in Policy Created Prior Stage Should be Training');break;
                    }
                    if(o.StageName == 'Training' && oldMap.get(o.Id).StageName != 'On Boarding'){o.addError(system.label.Stage_to_Training);break;
                        //o.addError('To Change in Training Prior Stage Should be On Boarding');break;
                    }
                    if(o.StageName == 'On Boarding' && oldMap.get(o.Id).StageName != 'Quote Accepted'){o.addError(system.label.Stage_to_On_Boarding);break;
                        //o.addError('To Change in On Boarding Prior Stage Should be Quote Accepted And Quote Accepted');break;
                    }
                    if(o.StageName == 'Quote Accepted' && oldMap.get(o.Id).StageName != 'RFQ'){o.addError(system.label.Stage_to_Quote_Accepted);break;
                        //o.addError('To Change in Quote Accepted Prior Stage Should be RFQ');break;
                    }
                    if(o.StageName == 'RFQ' && oldMap.get(o.Id).StageName != 'Discovery'){o.addError(system.label.Stage_to_RFQ);break;
                        //o.addError('To Change in RFQ Prior Stage Should be Discovery');break;
                    }
                    if(o.StageName == 'Discovery' && oldMap.get(o.Id).StageName != 'Lead'){o.addError(system.label.Stage_to_Discovery);break;
                        //o.addError('To Change in Discovery Prior Stage Should be Lead');break;
                    }
                    if(o.StageName == 'Lead' && oldMap.get(o.Id).StageName != 'Lead'){o.addError(system.label.Stage_Lead_Error);
                    }
                }
                if(o.Quote_Accepted__c == false){
                    if(o.StageName == 'On Boarding'){o.addError(system.label.Stage_On_boarding_and_QuoteAcceptedFalse);break;
                        //o.addError('Proposal Documents should be Signed');
                    }
                   /* if(o.StageName == 'Quote Accepted'){o.addError(system.label.Stage_Quote_Accepted_but_Quote_Not_Signed);break;
                        //o.addError('Proposal Documents should be Signed');
                    }*/
                }
                if(o.All_Documents_Collected__c == false){
                    if(o.StageName == 'On Boarding' ){o.addError(system.label.Stage_On_boarding_and_Docs_collected_false);break;
                        //o.addError('All Required Documents Should be Collected');
                    }
                }
                if(o.Mandate_Signed__c == false){
                    if(o.StageName == 'Quote Accepted' ){o.addError(system.label.Stage_Quote_Accepted_and_Discovery_docs_signed_false);break;
                        //o.addError('Descovery Docs Should be Signed');
                    }
                    if(o.StageName == 'RFQ' ){o.addError(system.label.Stage_Rfq_and_Discovery_Docs_signed);break;
                        //o.addError('Discovery Docs Should be Signed');
                    }   
                }
                if(o.Mfi_Completed__c == false){
                    if(o.StageName == 'Training'){o.addError(system.label.Stage_Training_and_Mfi_Completed);break;
                    }
                    if(o.StageName == 'Policy Created'){o.addError(system.label.Stage_Policy_Created_and_Mfi_completed);break;
                    }
                }
            }
        }
    }
}