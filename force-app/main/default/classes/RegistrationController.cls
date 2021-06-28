/*
	---------------------------------------------------------------------------------------------------------------------------
	Author:			Lyndi WK 
	Description:	Controller class for registrationForm LWC
    Test Class:     Registration Controller Test

	History
	<Date>			<Authors Name>		<User Story>		<Brief Description of Change>
	2021-06-26  	Lyndi WK			        			Class Creation
	---------------------------------------------------------------------------------------------------------------------------
*/

public with sharing class RegistrationController {

    // ************************************************************************************ //
	// ** Description:  Used to query Meetup data for Registration Form                  ** //
	// ** Inputs: String Registration Code                                               ** //
	// ** Outputs: Associated Meetup record                         			         ** //														 
	// ************************************************************************************ //
    
    @AuraEnabled(cacheable=true)
    public static Meetup__c getMeetupRcd(String regCode) {
        
        // Query for Meetup Data
        List<Meetup__c> meetups =   [SELECT Id, Name, Registrations__c, Registration_Limit__c, Status__c FROM Meetup__c 
                                    WHERE RegistrationCode__c = :regCode];

        if (meetups.size() > 0) {
            return meetups[0];
        } else {
            return new Meetup__c();
        }
    }

    
    // ************************************************************************************ //
	// ** Description:  Used to validate Registration Form Data                          ** //
	// ** Inputs: Registrant Email & Meetup Id                                           ** //
	// ** Outputs: String Error Message                              			         ** //														 
	// ************************************************************************************ //

    @AuraEnabled(cacheable=true)
    public static String validateRegistration(String email, Id meetupId) {
        
        // Instantiate error message to be returned
        String errMsg = '';

        // Query for Meetup Data with 
        List<Meetup__c> meetups =   [SELECT Id, Name, Registrations__c, Registration_Limit__c, Status__c, 
                                    (SELECT Id FROM Meetup_Registrations__r WHERE Email__c = :email)
                                    FROM Meetup__c 
                                    WHERE Id = :meetupId];
        
        // Perform checks on registration to confirm it is valid
        if (meetups.size() > 0) {

            Meetup__c meetup = meetups[0];

            // If there is already a Meetup Registration using the same Email, prevent registration
            if (meetup.Meetup_Registrations__r.size() > 0) {
                errMsg = 'Sorry, there is already a registration for this Meetup using the provided email!';
                return errMsg;
            }

            // If the Meetup status is Closed or at Capacity, prevent registration
            if (meetup.Status__c != 'Open' || meetup.Registrations__c >= meetup.Registration_Limit__c) {
                errMsg = 'Sorry, this Meetup is no longer open for registration!';
                return errMsg;
            }
        }

        return errMsg;
    }
}
