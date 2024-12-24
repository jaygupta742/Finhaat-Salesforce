({
    doInit : function(component, event, helper) {
        // Get the recordId
        var recordId = component.get("v.recordId");
        
        // Call server-side controller method with recordId as a parameter
        var action = component.get("c.check_signed_status");
        action.setParams({ "recid": recordId });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            // alert(state)
            if (state === "SUCCESS") {
                 
                // Show success toast message
                let res = response.getReturnValue();
              if(res=='Already signed..!!')res='Status is unsigned';
                if(res.includes('signed') && !res.includes('unsigned')){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message":res,
                        "type": "success"
                    });
                    toastEvent.fire();
                }
                else   if(res.includes('completed')){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message":res,
                        "type": "success"
                    });
                    toastEvent.fire();
                }
                    else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "",
                            "message":res,
                            "type": "warning"
                        });
                        toastEvent.fire();
                    }
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": recordId,
                    "slideDevName": "detail"
                });
                navEvt.fire();
            }   if (state === "ERROR") {
                let err = response.getError();
                let title = 'Error';
                let   type = 'error';
                let mssg =err[0].message;
                if(mssg=="Unexpected character ('s' (code 115)): expected a valid value (number, String, array, object, 'true', 'false' or 'null') at input location [1,2]"){
                    mssg =mssg.replace("Unexpected character ('s' (code 115)): expected a valid value (number, String, array, object, 'true', 'false' or 'null') at input location [1,2]",'Internal Server Error for "Mandate Signed" or "Proposal"')
                }
                alert( mssg);
                
                var navEvt = $A.get("e.force:navigateToSObject"); 
                navEvt.setParams({
                    "recordId": recordId,
                    "slideDevName": "detail"
                });
                navEvt.fire();
            }
        });
        $A.enqueueAction(action); 
    }
})