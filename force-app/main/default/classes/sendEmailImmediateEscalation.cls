//Created By Vishal Singh, Created Date:- 12-12-2024, Description:- Need to send the email when stage is Escalated and Escalated Date is not null... 
public class sendEmailImmediateEscalation {
    public static void sendEmailOnEscalation(List<Ticket__c> newTickets, Map<Id, Ticket__c> oldTicketMap) {
        List<Ticket__c> ticketsToEmail = new List<Ticket__c>();

        // Loop through the new ticket records
        for (Ticket__c newTicket : newTickets) {
            Ticket__c oldTicket = oldTicketMap.get(newTicket.Id);

            // Check if Stage__c is updated to 'Escalated' and Escalated_Date__c is not null
            if (newTicket.Stage__c == 'Escalated' && newTicket.Escalated_Date__c != null &&
                (oldTicket.Stage__c != 'Escalated' || oldTicket.Escalated_Date__c == null)) {
                ticketsToEmail.add(newTicket);
            }
        }

        // Send email if there are tickets to process
        if (!ticketsToEmail.isEmpty()) {
            sendEmailForEscalation(ticketsToEmail);
        }
    }

    private static void sendEmailForEscalation(List<Ticket__c> ticketsToEmail) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Id> ownerIds = new List<Id>();

        // Collect Owner IDs for querying user details
        for (Ticket__c ticket : ticketsToEmail) {
            ownerIds.add(ticket.OwnerId);
        }

        // Query owner and manager information
        Map<Id, User> ownerMap = new Map<Id, User>([SELECT Id, Name,Email, ManagerId, Manager.Email FROM User WHERE Name = 'Sanket Prabhu']);

        for (Ticket__c ticket : ticketsToEmail) {
            User owner = ownerMap.get(ticket.OwnerId);

            if (owner != null && owner.Email != null) {
               String emailBody = '<html>' +
                    '<body>' +
                    '<p>Dear Sanket Sir,</p>' +
                    '<p>The following ticket has been escalated and requires your attention:</p>' +
                    '<table>' +
                    '<tr><td><b>Ticket No.:</b></td><td>' + (ticket.Name != null ? ticket.Name : '') + '</td></tr>' +
                    '<tr><td><b>Category.:</b></td><td>' + (ticket.Category__c != null ? ticket.Category__c : '') + '</td></tr>' +
                    '<tr><td><b>Requirement.:</b></td><td>' + (ticket.text__c != null ? ticket.text__c : '') + '</td></tr>' +
                    '<tr><td><b>Stage:</b></td><td>' + (ticket.Stage__c != null ? ticket.Stage__c : '') + '</td></tr>' +
                    '<tr><td><b>Escalated Date:</b></td><td>' + (ticket.Escalated_Date__c != null ? ticket.Escalated_Date__c.format() : '') + '</td></tr>' +
                    '<tr><td><b>Owner:</b></td><td>' + (owner.Name != null ? owner.Name : '') + '</td></tr>' +
                    '</table>' +
                    '<p>Please review and take necessary action.</p>' +
                    '<p>Best Regards,<br>Your Salesforce Automation</p>' +
                    '</body>' +
                    '</html>';

                
				System.debug('owner.Manager.Email######'+owner.Manager.Email);

                // Prepare the email message
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] {owner.Email});
                //email.setToAddresses(new String[] {'vishalbanna1995@gmail.com'});
                email.setSubject('Escalated Ticket Notification');
                email.setHtmlBody(emailBody);
                emails.add(email);
            }
        }
        
        // Send emails
        if (!emails.isEmpty()) {
            try {
                // Log the recipients of the emails
                for (Messaging.SingleEmailMessage email : emails) {
                    System.debug('Email will be sent to: ' + String.join(email.getToAddresses(), ', '));
                }
                
                // Send the emails
                Messaging.sendEmail(emails);
                System.debug('Escalation emails sent successfully.');
            } catch (Exception e) {
                System.debug('Error sending escalation emails: ' + e.getMessage());
            }
        }
        
    }
}