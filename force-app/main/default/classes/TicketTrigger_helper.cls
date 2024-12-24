public class TicketTrigger_helper {
    public static void update_method(List<Ticket__c> ticRec, Map<Id, ticket__c> oldTicket){
        for(Ticket__c tk : ticRec){
            if(tk.Stage__c != null && tk.Stage__c != oldTicket.get(tk.Id).Stage__c){
                tk.In_progess__c = false;
                tk.Ticket_In_Progress_Date_Time__c = null;
                tk.TIcket_User__c = null;
            }
        }
    }
}