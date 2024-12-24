public class updateStatusToEscalatedScheduler implements Schedulable {
    
    public void execute(System.SchedulableContext SchedulableContext){
        
        // Log the start of the scheduled job execution
        System.debug('Starting the updateStatusToEscalatedScheduler job.');
        
        List<Ticket__c> ticketList = [SELECT Id, Stage__c, Due_Date__c FROM Ticket__c WHERE Stage__c = 'Ticket Raised' AND Due_Date__c != null];
        
        // Log the number of tickets fetched
        System.debug('Fetched ' + ticketList.size() + ' tickets that are in "Ticket Raised" stage with non-null Due Date.');
        
        List<Ticket__c> ticketsToBeUpdated = new List<Ticket__c>();
        
        Date todayDate = Date.today(); // Get today's date once to optimize
        System.debug('Today\'s date is: ' + todayDate);
        
        // Loop through all the tickets to check if they need escalation
        for (Ticket__c ticketRecord : ticketList) {
            Date dueDate = ticketRecord.Due_Date__c.addDays(2); // Add 2 days to Due Date
            System.debug('Ticket ID: ' + ticketRecord.Id + ', Due Date: ' + ticketRecord.Due_Date__c + ', Due Date + 2: ' + dueDate);
            
            // Check if today is the due date + 2 days
            if (todayDate == dueDate) {
                ticketRecord.Stage__c = 'Escalated';
                ticketsToBeUpdated.add(ticketRecord);
                System.debug('Ticket ID ' + ticketRecord.Id + ' is escalated.');
            }
        }
        
        system.debug(ticketsToBeUpdated);
        
        // Log if there are any tickets to update
        if (!ticketsToBeUpdated.isEmpty()) {
            System.debug('There are ' + ticketsToBeUpdated.size() + ' tickets to update to "Escalated".');
            try {
                Database.update(ticketsToBeUpdated, false); // Partial success allowed
                System.debug('Successfully updated ' + ticketsToBeUpdated.size() + ' tickets.');
            } catch (DmlException e) {
                System.debug('Error while updating tickets: ' + e.getMessage());
            }
        } else {
            System.debug('No tickets need to be escalated.');
        }
        
        // Log the end of the scheduled job execution
        System.debug('Completed the updateStatusToEscalatedScheduler job.');
    }
}