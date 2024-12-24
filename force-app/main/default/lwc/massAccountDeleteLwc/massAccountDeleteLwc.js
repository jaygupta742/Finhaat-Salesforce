import { LightningElement, api, track } from 'lwc';
import deleteAccounts from '@salesforce/apex/massAccountDeleteClass.deleteAccounts';
import LightningAlert from 'lightning/alert';
export default class MassAccountDeleteLwc extends LightningElement {
    @api recordIds;
    arrayofString;
    selectedRecords;

    connectedCallback(){
        var stringWithoutBrackets = this.recordIds.slice(1, -1);
        this.arrayofString = stringWithoutBrackets.split(", ");
        if(this.recordIds.length == 2){
            this.selectedRecords = 0;
        }else{
            this.selectedRecords = this.arrayofString.length;
        }
    }

    handleDeleteRecords(){
        if(this.arrayofString == ''){
            this.handleAlertClick('Please Select Records To Delete', 'error', 'Error');
        }
        else{
            deleteAccounts({accIds:this.arrayofString})
            .then(result =>{
                console.log('Result is : '+JSON.stringify(result));
                if(result == 'Success'){
                    this.handleAlertClick('Records Deleted Successfully', 'success', 'Success');
                    setTimeout(() => {
                        history.back();
                    }, 2000);
                }
                else{
                    this.handleAlertClick('Something is Wrong', 'error', 'Error');
                }
            })
            .catch(error =>{
                console.log('Error is : '+JSON.stringify(error))
            })
        }
    }
    async handleAlertClick(message, theme, label) {
        await LightningAlert.open({
            message: message,
            theme: theme,
            label: label,
        });
    }
}