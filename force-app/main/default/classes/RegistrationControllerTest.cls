/*
	---------------------------------------------------------------------------------------------------------------------------
	Author:			Lyndi WK 
	Description:	Test class for RegistrationController

	History
	<Date>			<Authors Name>		<User Story>		<Brief Description of Change>
	2021-06-26  	Lyndi WK			        			Class Creation
	---------------------------------------------------------------------------------------------------------------------------
*/


@isTest
private class RegistrationControllerTest {

    @TestSetup
    static void setupData(){

        // Create a Meetup Record
        Meetup__c meetup = new Meetup__c();
        meetup.Name = 'Sample Meetup';
        meetup.Registration_Limit__c = 2;
        meetup.Status__c = 'Open';
        insert meetup;
    }

    /**
     *  This Test validates that a Meetup record is returned when supplied a Registration Code
     */

    @isTest
    private static void verifyMeetupReturned() {

        // Query for Meetup created in Setup to get Registration Code
        Meetup__c meetup = [SELECT Id, RegistrationCode__c FROM Meetup__c LIMIT 1];

        Test.startTest();

        // Call Controller Method to fetch record
        Meetup__c fetchedMeetup = RegistrationController.getMeetupRcd(meetup.RegistrationCode__c);

        Test.stopTest();

        // Validate expected record is returned
        System.assertEquals(meetup.Id, fetchedMeetup.Id, 'Unexpected Meetup Record was found.');

    }

    /**
     *  This Test validates that an empty Meetup record is returned when an invalid Registration Code is supplied.
     */

    @isTest
    private static void verifyNOMeetupReturned() {
        
        Test.startTest();

        // Call Controller Method to fetch record using an invalid registration code
        Meetup__c fetchedMeetup = RegistrationController.getMeetupRcd('12345');

        Test.stopTest();

        // Validate emtpy record is returned
        System.assertEquals(null, fetchedMeetup.Id, 'No meetup should be found for invalid registration code.');

    }

    /**
     *  This Test validates that Registration is not created if a Meetup is in Closed Status
     */

    
    @isTest
    private static void verifyMeetupClosed() {

        // Query for Meetup created in Setup & update it to Closed
        Meetup__c meetup = [SELECT Id, RegistrationCode__c FROM Meetup__c LIMIT 1];       
        meetup.Status__c = 'Closed';
        update meetup;
        
        Test.startTest();

        // Call Controller Method to validate new registration
        String msg = RegistrationController.validateRegistration('test@email.com', meetup.Id);

        Test.stopTest();

        // Validate expected error message is returned
        System.assertEquals(msg, 'Sorry, this Meetup is no longer open for registration!', 'Error Message should indicate Meetup is closed.');

    }

    /**
     *  This Test validates that a Registration is not created if an existing Registration for the same email & Meetup exists.
     */


    @isTest
    private static void verifyDuplicateEmailPrevented() {

        // Query for Meetup created in Setup & update it to Closed
        Meetup__c meetup = [SELECT Id, RegistrationCode__c FROM Meetup__c LIMIT 1];       

        // Create a Meetup Registration
        Meetup_Registration__c registration = new Meetup_Registration__c();
        registration.FirstName__c = 'Person';
        registration.LastName__c = 'Test';
        registration.Email__C = 'person@test.com';
        registration.Meetup__c = meetup.Id;
        insert registration;

        Test.startTest();

        // Call Controller Method to validate new registration
        String msg = RegistrationController.validateRegistration('person@test.com', meetup.Id);

        Test.stopTest();

        // Validate expected record is returned
        System.assertEquals(msg, 'Sorry, there is already a registration for this Meetup using the provided email!', 'Error Message should indicate Meetup has a duplicate registrant.');

    }



}