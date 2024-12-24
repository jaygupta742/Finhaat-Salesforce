({
	getedu : function(component, event, helper) {
        console.log('------------ getpo() --------------');
        
		var action = component.get("c.educationhistory");
        
        
        
        action.setCallback(this, function(res){
            var state = res.getState();
           console.log("State : " + state);
            

            var result = res.getReturnValue();
          console.log("Return Value : " + result);
            
            if(state === "SUCCESS"){
                component.set("v.getedu", result);
            }
        });
        
        $A.enqueueAction(action); }
})