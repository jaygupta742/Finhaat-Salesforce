/*	Created Date : 18/04/2024 
	Created By : Vijay Somvanshi 
*/
trigger Log_call_trigger_for_count on Task (after insert,after Update) {
    if(trigger.isinsert && trigger.isafter){
        Log_Call_Count.logcallmethod(trigger.new);
        Log_count_Act_Evt.logmethodTask(trigger.new);
        Log_Count_opp_Act_Evt.logmethodTask(trigger.new);
    }
     if(trigger.Isupdate && trigger.Isafter){
        Log_Call_Count.logcallmethod(trigger.new);
        Log_count_Act_Evt.logmethodTask(trigger.new);
        Log_Count_opp_Act_Evt.logmethodTask(trigger.new);
    }
}