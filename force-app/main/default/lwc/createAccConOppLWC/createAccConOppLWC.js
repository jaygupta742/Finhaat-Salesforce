/*
 * @Created By   : Vishal Singh 
 * @Created Date : 29-08-2024
 * @Description  : Need to create a LWC component to create account, contact and opportunity form List view button on account 
 */
import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import LightningAlert from 'lightning/alert';
import modal from '@salesforce/resourceUrl/createAccConOppLWC';
import { loadStyle } from "lightning/platformResourceLoader";


import getDetails from '@salesforce/apex/createAccConOppLWC.get_Details';
import saveQuote from '@salesforce/apex/createAccConOppLWC.save';



export default class CreateAccConOppLWC extends NavigationMixin(LightningElement) {

    @api recordId;
    @api objectApiName;


    @track showSpinner = true;
    @track saveStatus = false;
    @track quote;
    //@track acc;
    //@track con;
    //@track opp;

    @track acc = {};
    @track con = {};
    @track opp = {};
    @track loc = {};
    @track quoteLineItems = [];
    @track showTypeOfStoreOther = false;
    
   

    connectedCallback() {
        Promise.all([
            loadStyle(this, modal)
        ])
    }

    // wire service-----
    wireServiceResponse;

    @wire(getDetails)
    async on_callback(response) {

        console.log("Response is" + response);

        this.wireServiceResponse = response;
        let data = response.data;
        let error = response.error;

        if (data) {

            let rval = JSON.parse(data);
            this.acc = rval.acc;
            this.con = rval.con;
            this.opp = rval.opp;
            this.loc = rval.loc;
            //this.quoteLineItems = rval.soItem;
            this.showSpinner = false;
        }
        if (error) {

            let errorMessage = error.body.message;
            this.showAlert(errorMessage, 'error', 'Error!', () => {
                this.cancelit();
            });
        }
    }
   
    async setAccountValues(event) {
        let fieldName = event.target.fieldName;
        let value = event.target.value;
        this.acc[fieldName] = value;
        if (fieldName === 'Type_Of_Store__c') {
            this.showTypeOfStoreOther = (value === 'Others');
        }
    }
    

    async setContactValues(event) {
        let fieldName = event.target.fieldName;
        let value = event.target.value;
        this.con[fieldName] = value;

    }

     async setlocationValues(event) {
        let fieldName = event.target.fieldName;
        let value = event.target.value;
        this.loc[fieldName] = value;

    }

    async setOpportunityValues(event) {
        let fieldName = event.target.fieldName;
        let value = event.target.value;
        this.opp[fieldName] = value;

    }

    async setQuoteValues(event) {
        let fieldName = event.target.fieldName;
        let value = event.target.value;

        this.quote[fieldName] = value;

        if (fieldName == 'Delivery_Terms__c') {
            this.showDeliveryTermsOthers = value === 'others';
        }
        if (fieldName == 'Payment_Terms__c') {
            this.showPaymentTermsOthers = value === 'Others';
        }
    }

    async setQuoteItemsValues(event) {
        let index = event.target.name;
        let fieldName = event.target.label;
        let value = event.target.value;

        this.quoteLineItems[index].qli[fieldName] = value;
    }

    async saveit() {
       /* if (this.quoteLineItems.length > 1) {
             let title = 'Error';
            let message = 'Only one line item can be there under one Sales Order.';
             this.showToast(title, message, 'error');
            return;
        }*/


        this.showSpinner = true;
        this.saveStatus = true;

          // Retrieve the PAN_No__c field from the account object
    let panNumber = this.acc.PAN_No__c;

    // PAN validation regex pattern
    const panPattern = /^[A-Z]{5}[0-9]{4}[A-Z]{1}$/;

    // Check if PAN number is not blank and doesn't match the required pattern
    if (panNumber && !panPattern.test(panNumber)) {
        // Set an error message or handle it according to your logic
        this.showToast('Error', 'Invalid PAN Number. Format should be 5 uppercase letters, followed by 4 digits, and ending with 1 uppercase letter.', 'error');
        this.showSpinner = false;
        this.saveStatus = false;
        return;
    }

    // Validate Phone Number before saving
    const phonePattern = /^[0-9]*$/;
    if (!phonePattern.test(this.acc.Phone)) {
        this.showToast('Error', 'The phone number must contain numeric characters.', 'error');
        this.showSpinner = false;
        this.saveStatus = false;
        return;
    }

    // Validation for special characters in Name
    const specialCharPattern = /[!@#$%^&*()\-_+=\[\]{}|\\:;"'<>,./?~`]/;
    if (specialCharPattern.test(this.acc.Name)) {
        this.showToast('Error', 'The Name field must not contain any special characters.', 'error');
        this.showSpinner = false;
        this.saveStatus = false;
        return;
    }

    // Validation for the Phone number field
    // if (!phonePattern.test(this.con.Phone)) {
    //     this.showToast('Error', 'Contact Phone number must contain only numeric characters.', 'error');
    //     this.showSpinner = false;
    //     this.saveStatus = false;
    //     return;
    // }

    // Validation for checking the phone number length
    // if (this.con.Phone && this.con.Phone.length !== 10) {
    //     this.showToast('Error', 'Phone number should be exactly 10 digits.', 'error');
    //     this.showSpinner = false;
    //     this.saveStatus = false;
    //     return;
    // }


    // Validation for the Phone number field
    if (!phonePattern.test(this.con.MobilePhone)) {
        this.showToast('Error', 'Contact MobilePhone number must contain only numeric characters.', 'error');
        this.showSpinner = false;
        this.saveStatus = false;
        return;
    }

    // Validation for checking the phone number length
    if (this.con.MobilePhone && this.con.MobilePhone.length !== 10) {
        this.showToast('Error', ' Contact MobilePhone number should be exactly 10 digits.', 'error');
        this.showSpinner = false;
        this.saveStatus = false;
        return;
    }


        if(!this.acc.Name){
            
                this.showToast('Error', 'Account Name must be filled.', 'error');
                this.showSpinner = false;
                this.saveStatus = false;
                return;
        }

        if(!this.acc.BillingStreet){
            
            this.showToast('Error', 'Account Billing Street must be filled.', 'error');
            this.showSpinner = false;
            this.saveStatus = false;
            return;
    }
    if(!this.acc.BillingCity){
            
        this.showToast('Error', 'Account Billing City must be filled.', 'error');
        this.showSpinner = false;
        this.saveStatus = false;
        return;
}
if(!this.acc.BillingState){
            
    this.showToast('Error', 'Account Billing State must be filled.', 'error');
    this.showSpinner = false;
    this.saveStatus = false;
    return;
}
if(!this.acc.BillingPostalCode){
            
    this.showToast('Error', 'Account Billing PostalCode must be filled.', 'error');
    this.showSpinner = false;
    this.saveStatus = false;
    return;
}
if(!this.acc.BillingCountry){
            
    this.showToast('Error', 'Account Billing Country must be filled.', 'error');
    this.showSpinner = false;
    this.saveStatus = false;
    return;
}


if(!this.acc.Total_Loan_Clients__c){
            
    this.showToast('Error', 'Account Total Loan Clients must be filled.', 'error');
    this.showSpinner = false;
    this.saveStatus = false;
    return;
}
if(!this.acc.Present_Insurance_Offerring__c){
            
    this.showToast('Error', 'Account Present Insurance Offerring must be filled.', 'error');
    this.showSpinner = false;
    this.saveStatus = false;
    return;
}
if(!this.acc.Total_Depositors__c){
            
    this.showToast('Error', 'Account Total Depositors must be filled.', 'error');
    this.showSpinner = false;
    this.saveStatus = false;
    return;
}

        
        if(!this.con.LastName){
                this.showToast('Error', 'Contact Last Name must be filled.', 'error');
                this.showSpinner = false;
                this.saveStatus = false;
                return;
        }

        if(!this.con.Email){
            this.showToast('Error', 'Contact Email must be filled.', 'error');
            this.showSpinner = false;
            this.saveStatus = false;
            return;
        }
        if(!this.con.MobilePhone){
            this.showToast('Error', 'Contact MobilePhone must be filled.', 'error');
            this.showSpinner = false;
            this.saveStatus = false;
            return;
        }
        if(!this.con.Title){
            this.showToast('Error', 'Contact Designation must be filled.', 'error');
            this.showSpinner = false;
            this.saveStatus = false;
            return;
        }


        if(this.opp.StageName == 'Closed Won' && !this.opp.Offer_No__c){
                this.showToast('Error', 'Please mention the Offer No. if the stage is "Closed Won"', 'error');
                this.showSpinner = false;
                this.saveStatus = false;
                return;
        }

        if(!this.opp.Name){
            
            this.showToast('Error', 'Opportunity Name must be filled.', 'error');
            this.showSpinner = false;
            this.saveStatus = false;
            return;
    }

        if(this.opp.StageName == 'Closed Won' && !this.opp.Offer_Date__c){
                this.showToast('Error', 'Please mention the Offer Date if the stage is "Closed Won"', 'error');
                this.showSpinner = false;
                this.saveStatus = false;
                return;
        }

        if(this.opp.Offer_No__c && !this.opp.Offer_Date__c){
                this.showToast('Error', 'Please mention the Offer Date if the Offer No. is mentioned.', 'error');
                this.showSpinner = false;
                this.saveStatus = false;
                return;
        }


        saveQuote({
            acc: JSON.stringify(this.acc),
            con: JSON.stringify(this.con),
            opp: JSON.stringify(this.opp)
        }).then(response => {
            console.log(JSON.stringify(response));
            let rval = response;

            if(rval === 'Account already exits'){
                this.showToast('Error', 'Account already exits with the same Name Or Website Or GST No Or PAN No', 'error');
                this.showSpinner = false;
                this.saveStatus = false;
                return;
            } else{
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: rval,
                        objectApiName: 'Account',
                        actionName: 'view'
                    }
                });
    
                let title = 'Success!!';
                let message = 'Account Contact and Opportunity Created Successfully !!!';
    
                this.showToast(title, message, 'success');
            }
           
        }).catch(error => {
            let errorMessage = error.body.message;
            /*this.showAlert(errorMessage, 'error', 'Error!', () => {
                return;
            });*/
            this.showSpinner = false;
            this.saveStatus = false;
        });
    }

  


    async showAlert(message, theme, label, ff) {
        await LightningAlert.open({
            message: message,
            theme: theme,
            label: label,
        });
        console.log('Alert has been closed');
        ff();
    }

    deleteitold(event) {
        console.log(event.target.dataset.id);
        let index = Number(event.target.dataset.id);

        this.quoteLineItems.splice(index, 1);
    }
    deleteit(event) {

        console.log(event.target.dataset.id);
        let index = Number(event.target.dataset.id);

        this.quoteLineItems.splice(index, 1);
        let quoteLineItems = []
        let sno = 0;
        for (let item of this.quoteLineItems) {
            sno = sno + 1;
            item.index = sno;
            quoteLineItems.push(item);
        }
        this.quoteLineItems = lstOpli;
        window.setTimeout(() => { this.isLoading = false; }, 500);
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    cancelit() {
        // Navigate to the recently viewed list of the Account object
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account', // Specify the object API name
                actionName: 'list' // This will navigate to the object's default list view
            },
            state: {
                filterName: 'Recent' // Specify the 'Recently Viewed' list view
            }
        });
    }

    get discountTypeOptions() {
        return [
            { label: '%', value: '%' },
            { label: 'Amount', value: 'Amount' },
        ];
    }
}