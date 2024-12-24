trigger LogcountOn_Event on Event (after insert,after update) {
    if(trigger.isinsert && trigger.isafter){
        Log_count_Act_Evt.logmethodEvent(trigger.new);
        Log_Count_opp_Act_Evt.logmethodEvent(trigger.new);
    }
    
     if(trigger.IsUpdate && trigger.Isafter){
        Log_count_Act_Evt.logmethodEvent(trigger.new);
        Log_Count_opp_Act_Evt.logmethodEvent(trigger.new);
    }
    
}