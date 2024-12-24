@RestResource(urlMapping = '/callyzerBizIncomming/*')
global class callyzerIncommingRestResource {
    @HttpPost
    global static String postRequest() {
        try {
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            
            String requestBody = req.requestBody.toString();
            
            set<String> phoneNumbers = new set<String>();
            map<String, Contact> mapOfContact = new map<String, Contact>();
            
            List<Object> listOfObjectRaw = (List<Object>)JSON.deserializeUntyped(requestBody);
            List<Map<String, Object>> listOfObject = new List<Map<String, Object>>();
            
            for (Object obj : listOfObjectRaw) {
                listOfObject.add((Map<String, Object>)obj);
            }
            
            // Collect phone numbers
            for (Map<String, Object> mapOfString_Object : listOfObject) {
                List<Object> listOfCallLogsRaw = (List<Object>)mapOfString_Object.get('call_logs');
                List<Map<String, Object>> listOfCallLogs = new List<Map<String, Object>>();
                
                for (Object callLogObj : listOfCallLogsRaw) {
                    listOfCallLogs.add((Map<String, Object>)callLogObj);
                }
                
                for (Map<String, Object> mapOfCallLog : listOfCallLogs) {
                    phoneNumbers.add((String)mapOfCallLog.get('client_number'));
                }
            }
            
            // Retrieve existing contacts
            for (Contact contact : [SELECT MobilePhone, AccountId FROM Contact WHERE MobilePhone IN :phoneNumbers]) {
                mapOfContact.put(contact.MobilePhone, contact);
            }
            
            map<String, Call_Detail__c> mapOfUniqueCallDetails = new map<String, Call_Detail__c>();
            
            for (Map<String, Object> mapOfString_Object : listOfObject) {
                List<Object> listOfCallLogsRaw = (List<Object>)mapOfString_Object.get('call_logs');
                List<Map<String, Object>> listOfCallLogs = new List<Map<String, Object>>();
                
                for (Object callLogObj : listOfCallLogsRaw) {
                    listOfCallLogs.add((Map<String, Object>)callLogObj);
                }
                
                for (Map<String, Object> mapOfCallLog : listOfCallLogs) {
                    String callId = (String)mapOfCallLog.get('id');
                    
                    // Avoid duplicates
                    if (!mapOfUniqueCallDetails.containsKey(callId)) {
                        if (mapOfContact.containsKey((String)mapOfCallLog.get('client_number'))) {
                            
                            Call_Detail__c callDetails = new Call_Detail__c();
                            
                            callDetails.Call_From__c = (String)mapOfString_Object.get('emp_number');
                            callDetails.Call_ID__c = callId;
                            callDetails.Call_To__c = (String)mapOfCallLog.get('client_number');
                            callDetails.Call_Type__c = (String)mapOfCallLog.get('call_type') == 'Outgoing' ? 'OutBound' : 'InBound';
                            callDetails.Status__c = 'Success';
                            
                            try{
                                String userPhone = '%' + callDetails.Call_From__c + '%';
                                User userRecord = [SELECT Name 
                                                   From User 
                                                   WHERE MobilePhone 
                                                   LIKE : userPhone OR Phone LIKE : userPhone];
                                
                                callDetails.OwnerId = userRecord.Id;
                            }catch(Exception e){
                                // No need for anything as no user is found the defualt site user will be the owner of the calling record.
                                system.debug('No User Related To The From Number Found.');
                            }
                            
                            if ((String)mapOfCallLog.get('call_type') == 'Rejected') {
                                callDetails.Call_Type__c = 'InBound';
                                callDetails.Status__c = 'Missed';
                            } else if ((String)mapOfCallLog.get('call_type') == 'Incoming' && Integer.valueOf(mapOfCallLog.get('duration')) == 0) {
                                callDetails.Call_Type__c = 'InBound';
                                callDetails.Status__c = 'Missed';
                            } else if ((String)mapOfCallLog.get('call_type') == 'Outgoing' && Integer.valueOf(mapOfCallLog.get('duration')) == 0) {
                                callDetails.Call_Type__c = 'OutBound';
                                callDetails.Status__c = 'Rejected';
                            }
                            
                            callDetails.Recording_File__c = (String)mapOfCallLog.get('call_recording_url');
                            callDetails.Duration__c = (Integer)mapOfCallLog.get('duration');
                            callDetails.Start_Time__c = convertStringIntoDateTime((String)mapOfCallLog.get('call_time'),(String)mapOfCallLog.get('call_date')).addMinutes(-330);
                            callDetails.End_Time__c = callDetails.Start_Time__c.addSeconds((Integer)mapOfCallLog.get('duration'));
                            
                            Contact contact = mapOfContact.get(callDetails.Call_To__c);
                            callDetails.Account__c = contact.AccountId;
                            callDetails.Contact__c = contact.Id;
                            mapOfUniqueCallDetails.put(callId, callDetails);
                        } 
                    }
                }
            }
            
            Database.upsert(mapOfUniqueCallDetails.values(), Call_Detail__c.Call_ID__c, false);
            return 'Success';
        } catch (Exception e) {
            system.debug(e.getMessage());
            system.debug(e.getLineNumber());
            //throw new AuraHandledException(e.getMessage());
            return e.getMessage() + ' ' + e.getLineNumber();
        }
    }
    
    global static DateTime convertStringIntoDateTime(String timeString,String dateString) {
        List<String> timeParts = timeString.split(':');
        Integer hours = Integer.valueOf(timeParts[0]);
        Integer minutes = Integer.valueOf(timeParts[1]);
        Integer seconds = Integer.valueOf(timeParts[2]);
        
        List<String> dateParts = dateString.split('-');
        Integer year = Integer.valueOf(dateParts[0]);
        Integer month = Integer.valueOf(dateParts[1]);
        Integer day = Integer.valueOf(dateParts[2]);
        
        return DateTime.newInstance(year, month, day, hours, minutes, seconds);
    }
}