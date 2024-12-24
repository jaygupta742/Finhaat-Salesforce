import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import LightningAlert from 'lightning/alert';
// import modal from '@salesforce/resourceUrl/Model';
// import { loadStyle } from "lightning/platformResourceLoader";

//import getDetails from '@salesforce/apex/NotifyOps.getDetails';
import saveAccount from '@salesforce/apex/NotifyOps.saveAccountDetails';
import getCustomObjectOptions from '@salesforce/apex/NotifyOps.getCustomObjectOptions';
import getUsers from '@salesforce/apex/NotifyOps.getUsers';
export default class NotifyOps extends NavigationMixin(LightningElement) {
 @api recordId;
 showToastBoolean = false;
 @api objectApiName;

    @track optionValue = '';
    @track showSpinner = true;
    @track saveStatus = false;
    @track isOtherSelected = false;
    @track task;

    @track task = {
        Subject: '',
        Comments: '',
        Priority: 'Normal',
        DueDate: this.getTodayDate(),
        OtherSubject: ''
    };

    get sobjectType () {
        return [
            { label: 'Users', value: 'Users' },
            { label: 'Queue', value: 'Queue' }
        ];
    }

    @track isShowModal = true;

    @track optionsQueue = [];
    @track selectedttValue = '00GJ4000000IPTHMA4';

    @wire(getCustomObjectOptions)
    wiredOptions({ error, data }) {
        if (data) {
            this.optionsQueue = data.map(optiony => {
                return { label: optiony.Name, value: optiony.Id };
            });
        } else if (error) {
            console.error('Error fetching optionsQueue', error);
        }
    }

    handlequeuChange(event) {
        this.selectedttValue = event.detail.value;
        console.log('Selected Value: >> ' +  this.selectedttValue);
    }


    showModalBox() {  
        this.isShowModal = true;
    }

    hideModalBox() {  
        this.isShowModal = false;
    }

     // Method to get today's date in 'dd-mm-yyyy' format
     getTodayDate() {
        const today = new Date();
        const day = String(today.getUTCDate()).padStart(2, '0');
        const month = String(today.getUTCMonth() + 1).padStart(2, '0'); // January is 0!
        const year = today.getUTCFullYear();
    
        return `${year}-${month}-${day}`;
            
        }

    get options() {
        return [
            { label: '--None--', value: '--None--' },
            { label: 'Call', value: 'Call' },
            { label: 'Send Letter', value: 'Send Letter' },
            { label: 'Send Quote', value: 'Send Quote' },
            { label: 'Other', value: 'Other' },
        ];
    }

    get PriorityOptions() {
        return [
            { label: '--None--', value: '--None--' },
            { label: 'High', value: 'High' },
            { label: 'Normal', value: 'Normal' },
            { label: 'Low', value: 'Low' },
        ];
    }


    handleInputChange(event) {
        const field = event.target.label; // Get the data-id attribute to identify the field
        const value = event.target.value;
        console.log(field);
        console.log(value);
        
        
        if(field === 'Due Date'){
            this.task.DueDate = value; 
            console.log(JSON.stringify(this.task));
        }else{
            this.task[field] = value; 
            console.log(JSON.stringify(this.task));
        }
        
    }

    async refreshData() {
        await refreshApex(this.wireServiceResult);
    }

    async saveit() {
        console.log('Subject >> ' + this.task.Subject);
        if (this.task.Subject.trim() == '' ) {
                //alert('Please Enter the Required Field:- Delivery Term.');
                let title = 'Error';
                let message = 'Please Enter the Required Field:- Subject.';
    
                this.showToast(title, message, 'error');
                this.saveStatus = false;
                return;
            }

            saveAccount({
                taskDetails: JSON.stringify(this.task),
                recordId : this.recordId,
                queueId : this.selectedttValue
            }).then(response => {
                let rval = response;
                console.log('rval####'+rval);
                this.showToastBoolean = true;
                this.navigateToTask(rval);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: ' Task created successfully.',
                        variant: 'success'
                    })
                );
                
                
            }).catch(error => {
                let errorMessage = error.body.message;
                this.showAlert(errorMessage, 'error', 'Error!', () => {
                    return;
                });
                this.showSpinner = false;
                this.saveStatus = false;
            });
		
        this.showSpinner = true;
        this.saveStatus = true;     
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

    navigateToTask(rval){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: rval,
                objectApiName: 'Task',
                actionName: 'view'
            }
        });
    }
    
    showToast(message, title, variant) {
                const event = new ShowToastEvent({
                    title: title,
                    message: message,
                    variant: variant,
                });
                this.dispatchEvent(event);
            }

    cancelit() {
        console.log('cancle button is clicked')
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view'
            }
        });
       
    }

    @track showDropdown = false;

    @track options = [
        { id: '1', label: 'Need to send Quotation' },
        { id: '2', label: 'Need to send Payment Link' },
        { id: '3', label: 'Need to create policy' },
        { id: '4', label: 'Need another Quotation from another IC' }
    ];

    handleMouseDown(event) {
        this.showDropdown = true;
    }

    @track filteredOptions = this.options;
    handleInputtChange(event) {
        const searchTerm = event.target.value.toLowerCase();
        console.log('Search Term:', searchTerm);

        this.filteredOptions = this.options.filter(option => 
            option.label.toLowerCase().includes(searchTerm)
        );

        console.log('Filtered Options:', this.filteredOptions);

        this.showDropdown = this.filteredOptions.length > 0;
        console.log('Show Dropdown:', this.showDropdown);
        this.optionValue = event.target.value;
        this.task.Subject = event.target.value;
        console.log(this.task.Subject);
    }

    handleOptionClick(event) {
        const selectedOptionId = event.currentTarget.dataset.id;
        const selectedOption = this.options.find(option => option.id === selectedOptionId);

        if (selectedOption) {
            this.selectedOptionLabel = selectedOption.label;
            this.optionValue = selectedOption.label; 
            this.task.Subject = this.optionValue;
            this.showDropdown = false; // Hide dropdown after selecting an option
        }
        
    }

    handleMouseDown(event) {
        this.showDropdown = true;
        event.stopPropagation();
    }

    @track selectedtypeValue1 = 'Queue';
    handleSelectType(event){
        this.selectedtypeValue1 = event.detail.value;
        console.log(event.detail.value);
        if(this.selectedtypeValue1  === 'Users'){
            this.selectedttValue = '005J4000001EItRIAW';
             getUsers().then(data => {
                     this.optionsQueue = data.map(optiony => {
                        return { label: optiony.Name, value: optiony.Id };
                    });
            }).catch(error => {
                let errorMessage = error.body.message;
                this.showAlert(errorMessage, 'error', 'Error!', () => {
                    return;
                });
                this.showSpinner = false;
                this.saveStatus = false;
            }); 
        }
        else if(this.selectedtypeValue1 === 'Queue'){
            this.selectedttValue = '00GJ4000000IPTHMA4';
            getCustomObjectOptions().then(data => {
                     this.optionsQueue = data.map(optiony => {
                        return { label: optiony.Name, value: optiony.Id };
                    });
            }).catch(error => {
                let errorMessage = error.body.message;
                this.showAlert(errorMessage, 'error', 'Error!', () => {
                    return;
                });
                this.showSpinner = false;
                this.saveStatus = false;
            }); 
        }
    }


  /*  connectedCallback() {
        // Add event listener for clicks outside the component
        document.addEventListener('mousedown', this.handleOutsideClick.bind(this));
    }

    disconnectedCallback() {
        // Remove event listener when component is destroyed
        document.removeEventListener('mousedown', this.handleOutsideClick.bind(this));
    }

    handleOutsideClick(event) {
        // Check if the click is outside the component
        const dropdownContainer = this.template.querySelector('.slds-dropdown');
        if (dropdownContainer && !dropdownContainer.contains(event.target)) {
            this.showDropdown = false;
        }
    }*/

    
}