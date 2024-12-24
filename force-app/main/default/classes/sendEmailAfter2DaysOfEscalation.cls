public class sendEmailAfter2DaysOfEscalation implements Schedulable {
    
    public void execute(System.SchedulableContext SchedulableContext) {
        System.debug('Starting the sendEmailAfter2DaysOfEscalation job.');
        
        // Query for tickets in "Escalated" stage with non-null Escalated_Date__c
        List<Ticket__c> ticketList = [SELECT Id, Stage__c, Escalated_Date__c, OwnerId, Name FROM Ticket__c WHERE Stage__c = 'Escalated' AND Escalated_Date__c != null];
        
        System.debug('Fetched ' + ticketList.size() + ' tickets that are in "Escalated" stage with non-null Escalated Date.');
        
        List<Ticket__c> ticketsToBeUpdated = new List<Ticket__c>();
        
        Date todayDate = Date.today();
        System.debug('Today\'s date is: ' + todayDate);
        
        // Loop through the tickets to check if they need to be escalated
        for (Ticket__c ticketRecord : ticketList) {
            Date dueDate = ticketRecord.Escalated_Date__c.addDays(2);  // Adding 2 days to the Escalated Date
            System.debug('Ticket ID: ' + ticketRecord.Id + ', Escalated Date: ' + ticketRecord.Escalated_Date__c + ', Due Date + 2: ' + dueDate);
            
            // Check if today is the due date + 2 days
            if (todayDate == dueDate) {
                ticketsToBeUpdated.add(ticketRecord);
                System.debug('Ticket ID ' + ticketRecord.Id + ' is escalated.');
            }
        }
        
        // Log if there are any tickets to update
        if (!ticketsToBeUpdated.isEmpty()) {
            System.debug('There are ' + ticketsToBeUpdated.size() + ' tickets to send emails about.');
            try {
                // Send email after processing the tickets
                sendEmailForEscalationToSanket(ticketsToBeUpdated);
                System.debug('Successfully sent email for ' + ticketsToBeUpdated.size() + ' tickets.');
            } catch (Exception e) {
                System.debug('Error sending email: ' + e.getMessage());
            }
        } else {
            System.debug('No tickets need to send email for.');
        }
        
        // Log the end of the scheduled job execution
        System.debug('Completed the sendEmailAfter2DaysOfEscalation job.');
    }
    
    public static void sendEmailForEscalationToSanket(List<Ticket__c> ticketsToBeUpdated) {
        // Email recipient
        String emailRecipient = 'jaysgupta742@gmail.com';
        
        // Prepare email subject
        String subject = 'Tickets Needing Attention Due to Escalation';
        
        // Start building the email body
        String emailBody = '<html>' +
            '<head>' +
            '<style>' +
            'body { font-family: Arial, sans-serif; color: #333; line-height: 1.6; }' +
            'h2 { color: #5a2a99; }' +
            'p { margin: 10px 0; }' +
            'table { width: 100%; border-collapse: collapse; margin-top: 20px; }' +
            'th, td { padding: 10px; text-align: left; border: 1px solid #ddd; }' +
            'th { background-color: #f2f2f2; color: #333; }' +
            'td { background-color: #f9f9f9; }' +
            'a { color: #2a5db0; text-decoration: none; }' +
            '</style>' +
            '</head>' +
            '<body>' +
            '<h2>Dear Sanket,</h2>' +
            '<p>The following tickets have been escalated and require your attention:</p>' +
            '<table>' +
            '<tr>' +
            '<th>Ticket</th>' +
            '<th>Stage</th>' +
            '<th>Escalated Date</th>' +
            '<th>Owner</th>' +
            '</tr>';
        
        // Loop through the list of tickets to construct the email body with ticket details
        for (Ticket__c ticket : ticketsToBeUpdated) {
            // Query the ticket owner information
            User ticketOwner = [SELECT Name FROM User WHERE Id = :ticket.OwnerId LIMIT 1];
            
            // Construct the link to the ticket record
            String ticketUrl = 'https://finhaatinsurancebrokingpvtltd.lightning.force.com/lightning/r/Ticket__c/' + ticket.Id + '/view';
            
            // Add ticket details to the email body in table format
            emailBody += '<tr>' +
                '<td><a href="' + ticketUrl + '">' + ticket.Name + '</a></td>' +
                '<td>' + ticket.Stage__c + '</td>' +
                '<td>' + ticket.Escalated_Date__c.format() + '</td>' +
                '<td>' + ticketOwner.Name + '</td>' +
                '</tr>';
        }
        
        // Closing the email body
        emailBody += '</table>' +
            '<p>Please review and take the necessary action.</p>' +
            '<p>Best Regards,<br>Your Salesforce Automation</p>' +
            '</body>' +
            '</html>';
        
        // Send the email with HTML body
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {emailRecipient});
        mail.setSubject(subject);
        mail.setHtmlBody(emailBody);
        
        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            System.debug('Email sent successfully to ' + emailRecipient);
        } catch (Exception e) {
            System.debug('Error sending email: ' + e.getMessage());
            throw new AuraHandledException('Failed to send email due to: ' + e.getMessage()); // Rethrow to capture error in debug
        }
    }
}