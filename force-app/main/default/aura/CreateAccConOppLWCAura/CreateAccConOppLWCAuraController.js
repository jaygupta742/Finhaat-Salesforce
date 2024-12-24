({
	doinit : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:createAccConOppLWC",
            componentAttributes: {
            }
        });
        evt.fire();
	},
    reinit: function(componet, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
})