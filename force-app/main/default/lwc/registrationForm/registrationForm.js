// Import Libraries
import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

// Import Controller Methods
import getMeetupRcd from '@salesforce/apex/RegistrationController.getMeetupRcd';
import validateRegistration from '@salesforce/apex/RegistrationController.validateRegistration';

// Alert Message Classes
const ERROR_CLASS = 'slds-notify slds-notify_alert slds-alert_error';
const SUCCESS_CLASS = 'slds-notify slds-notify_alert slds-theme_success';
const WARNING_CLASS = 'slds-notify slds-notify_alert slds-alert_warning';

export default class RegistrationForm extends LightningElement {

    //fields = [EMAIL_FIELD, FN_FIELD, LN_FIELD];
    currentPageReference;
    regCode;
    meetupRcd;
    doneLoading = true;
    submitDisabled = true;
    meetupId;
    userEmail;
    alertMsg;
    alertClass;

    /**
     * Processes Query Parameters to get Registration Code from URL
    */

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        this.currentPageReference = currentPageReference;

        if (this.currentPageReference.state.code) {
            this.regCode = this.currentPageReference.state.code;
        }
    }

    /**
     * Fetches Meetup Record on page load so that data is accessible when creating Meetup Registration
    */

    @wire(getMeetupRcd, { regCode: '$regCode'})
    wiredMeetupRcd({data, error}) {
        
        // Start spinner
        this.doneLoading = false;

        if (data) {
            // If record has an Id, a Meetup was found
            if (data.Id) {
                
                // Save Meetup Record Data
                this.meetupRcd = data;
                this.meetupId = this.meetupRcd.Id;

                // Check if Meetup is in an Open Status & has Available Spots
                if (this.meetupRcd.Status__c == 'Open' && this.meetupRcd.Registrations__c < this.meetupRcd.Registration_Limit__c) {
                    
                    // Stop Spinner & Enable Registration Button
                    this.doneLoading = true;
                    this.submitDisabled = false;

                } else {

                    // Turn off Spinner
                    this.doneLoading = true;

                    // Display Error since there are no available openings
                    this.alertMsg = 'Sorry, this Meetup is no longer open for registration!';
                    this.alertClass = WARNING_CLASS;
                }
                

            }  else { // Otherwise no Meetup exists to match Registration Code

                // Turn off Spinner
                this.doneLoading = true;
                
                // Display Error Message
                this.alertMsg = 'Sorry, your Meetup could not be found.  Please check your registration code.';
                this.alertClass = ERROR_CLASS;
            }
            
        }

        if (error) {
            // Turn off Spinner
            this.doneLoading = true;

            // Display Generic Error
            this.alertMsg = 'Sorry, there was an error fetching your Meetup information!';
            this.alertClass = ERROR_CLASS;
        }
    }

    /*
     * Performs Validation before Registration is Submitted
    */

    handleSubmit(event) {

        // prevent form from submitting so that validation can be done first
        event.preventDefault(); 

        // start spinner
        this.doneLoading = false;

        // call apex method to perform validation
        validateRegistration({ email : this.userEmail, meetupId : this.meetupId})
            .then((result) => {

                // If the result is not empty, there is an error message to display
                if (result != '') {
                    // Display Error Message
                    this.alertMsg = result;
                    this.alertClass = ERROR_CLASS;

                    // Turn off Spinner
                    this.doneLoading = true;

                } else {
                    // Complete submission of this registration
                    const fields = event.detail.fields;
                    this.template.querySelector('lightning-record-edit-form').submit(fields);
                }

            })
            .catch((error) => {

                // Stop spinner
                this.doneLoading = true;

                // Display Generic Error
                this.alertMsg = 'Sorry, there was an error with your registration!';
                this.alertClass = ERROR_CLASS;

            });        

    }

    /*
     * Displays a Success Alert if Registration was Successful
    */

    handleSuccess(event) {

        // Turn off Spinner
        this.doneLoading = true;

        // Displays Success Message
        this.alertMsg = this.meetupRcd.Name ? 'Congratulations, your registration for ' + this.meetupRcd.Name + ' was successful!' : 'Congratulations, your registraion was successful!';
        this.alertClass = SUCCESS_CLASS;
    }

    /*
     * Stores provided email so that it can be used for validation
    */

    handleEmailChange(event){
        this.userEmail = event.target.value;
    }

}