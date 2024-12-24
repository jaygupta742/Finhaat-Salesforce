({
    
    doInit : function(component, event, helper) {
        //  helper.getedu(component, event, helper); 
        //  helper.getPOrderLineItem(component,event, helper);
        // helper.getwarename(component, event, helper);
         // var lltp=component.get("v.masterdoclist"); 
           var action= component.get("c.getinstant"); 
        
        // Pass the recordId to the Apex method
        action.setParams({
            recId: component.get("v.recordId") // Ensure "v.recordId" is set in the component
        });
        
        action.setCallback(this,function(response){
            var status = response.getState();
            if(status==="SUCCESS"){
                component.set("v.masterdoclist",JSON.parse(response.getReturnValue()));
              //  alert('masterdoclist'+ JSON.parse(response.getReturnValue()));
                //component.set("v.show_spinner", false);        
            }
            else{
                console.log('inside else lijbd');
                // component.set("v.show_spinner", false);        
            }
        });
        $A.enqueueAction(action);
    },
    
    dd :function(component, event, helper){
        console.log('----on change-----')
        var filter = component.get("v.filter1");
        console.log('get new '+filter);
        if(filter =='' || filter == null){
            var toastevent = $A.get("e.force:showToast");
            toastevent.setParams({
                'title':'',
                'type':'error',
                'message':'Please select level of education'
            });
            return null;
        }
        component.set("v.flag",true);
        var action= component.get("c.getmasterdoc");
        
        
        action.setParams({
            // 'recId':component.get("v.recordId"),
            'stages': String(filter)
        });
        
        action.setCallback(this,function(response){
            var status = response.getState();
            if(status==="SUCCESS"){
                component.set("v.masterdoclist",JSON.parse(response.getReturnValue()));
                console.log('masterdoclist'+ JSON.parse(response.getReturnValue()));
                //component.set("v.show_spinner", false);        
            }
            else{
                console.log('inside else lijbd');
                // component.set("v.show_spinner", false);        
            }
        });
        $A.enqueueAction(action);
    },
    saveit : function(component, event, helper) {
      
        var masterdoc = component.get("v.masterdoclist"); 
        if(masterdoc.length==0){
            alert('Need at least one Required Document....')
            return;
        }
        for(let item of masterdoc){
            if(item.name.trim()==''){
                alert('Document Name Is Required ...!!!');
                return;
            }
        }
        var stages =component.get("v.filter1"); 
        var action = component.get("c.onsave");
        console.log('save is called');
        
        action.setParams({
            "recid" : component.get("v.recordId"),
            "reqdoc" : JSON.stringify(masterdoc),
            "stages" : stages
        });
        console.log('check 3******');
        action.setCallback(this, function(response) {
            var state = response.getState();
            var title, type, message;
            
            console.log(state);
            if(state === 'SUCCESS') {
                title='SUCCESS!!!';
                type='success';
                message="Required Documents created successfully!!!";
                
                var recordId=response.getReturnValue();
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/"+recordId
                });
                urlEvent.fire();
            }
            
            if(state === 'ERROR') {
                title = 'ERROR';
                type='error';
                let err = response.getError();
                
                message = err[0].message;
            }
            
            var toastevent = $A.get("e.force:showToast");
            toastevent.setParams({
                'title':title,
                'type':type,
                'message':message
            });
            
            toastevent.fire();
            component.set("v.save_btn_status", false	);
        });
        $A.enqueueAction(action);
        
    },
    
    saveitnotify : function(component, event, helper) {
        console.log('----------------- on save it notify---------------');
        
        var masterdoc = component.get("v.masterdoclist");
        console.log('masterdoclist'+masterdoc);
        var stages =component.get("v.filter1");
        component.set("v.save_btn_status", true);
        var action = component.get("c.onsavenotify");
        console.log('save is called');
        
        action.setParams({
            "recid" : component.get("v.recordId"),
            "reqdoc" : JSON.stringify(masterdoc),
            "stages" : stages
        });
        console.log('check 3******');
        action.setCallback(this, function(response) {
            var state = response.getState();
            var title, type, message;
            
            console.log(state);
            if(state === 'SUCCESS') {
                title='SUCCESS!!!';
                type='success';
                message="Required Documents created successfully and Notified!!!";
                
                var recordId=response.getReturnValue();
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/"+recordId
                });
                urlEvent.fire();
            }
            
            if(state === 'ERROR') {
                title = 'ERROR';
                type='error';
                let err = response.getError();
                
                message = err[0].message;
            }
            
            var toastevent = $A.get("e.force:showToast");
            toastevent.setParams({
                'title':title,
                'type':type,
                'message':message
            });
            
            toastevent.fire();
            component.set("v.save_btn_status", false	);
        });
        $A.enqueueAction(action);
        
    },
    
    
    addrow : function(component, event, helper) {
        //  component.set("v.add_more_btn_status", true);
        var lltp=component.get("v.masterdoclist"); 
        var obj={};
        obj.Quantity=1;
         obj.name= '';
                obj.instruction = '';
        lltp.push(obj);
        component.set("v.masterdoclist",lltp);
        // component.set("v.add_more_btn_status", false);
    },
    
    
    
    
    DeleteAction :function(component, event, helper){
        let index = event.getSource().get("v.value");
        let listItem = component.get("v.masterdoclist");
        listItem.splice(index,1);
        component.set("v.masterdoclist",listItem);
    },
    
    cancel : function(component, event, helper) {
        var recordId=response.getReturnValue();
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"+recordId
        });
        urlEvent.fire();
    }
    
})