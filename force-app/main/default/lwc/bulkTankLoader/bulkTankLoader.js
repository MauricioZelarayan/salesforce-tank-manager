import { LightningElement, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import PARSER from '@salesforce/resourceUrl/PapaParse'; 
import insertTanks from '@salesforce/apex/TankDataController.insertTanks'; 

// Columns for the Step 3 table.
const COLUMNS = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Serial Number', fieldName: 'Serial_Number__c' },
    { label: 'URL', fieldName: 'Long_URL__c' }
];

export default class BulkTankLoader extends LightningElement {
    isLoading = false;
    parserInitialized = false;
    
    // Step
    currentStep = "1";
    selectedTankTypeId = null;

    // Variables for create 
    mode = 'select'; // 'select' or 'create'
    @track newTypeData = { Name: '', Capacity__c: '', List_Price__c: '', Brand__c: '' };
    
    // Data
    @track parsedData = []; // Use @track because it's an array that changes
    columns = COLUMNS;

    // Getters for HTML (to show)
    get isStep1() { return this.currentStep === "1"; }
    get isStep2() { return this.currentStep === "2"; }
    get isStep3() { return this.currentStep === "3"; }

    get isModeSelect() { return this.mode === 'select'; }
    get isModeCreate() { return this.mode === 'create'; }
    
    get modeOptions() {
        return [
            { label: 'Select Existing', value: 'select' },
            { label: 'Create new', value: 'create' }
        ];
    }

    // "Next" button validation
    get disableNextStep1() {
        if (this.mode === 'select') {
            return !this.selectedTankTypeId; // Disabled if didn't choose
        } else {
            // Disabled if no Name, Capacity or List_Price
            return !(this.newTypeData.Name && this.newTypeData.Capacity__c && this.newTypeData.List_Price__c);
        }
    }

    renderedCallback() {
        if (!this.parserInitialized) {
            loadScript(this, PARSER)
                .then(() => { this.parserInitialized = true; })
                .catch(error => console.error(error));
        }
    }

    // Step 1 Logic

    handleModeChange(event) {
        this.mode = event.detail.value;
        this.selectedTankTypeId = null; // Reset the selection when the mode changes
    }

    handleTypeSelection(event) {
        // Catch the Lookup ID
        this.selectedTankTypeId = event.detail.value[0]; 
    }

    handleNewTypeChange(event) {
        const field = event.target.name;
        this.newTypeData = { ...this.newTypeData, [field]: event.target.value };
    }

    handleNext() {
        if (this.mode === 'select') {
            // If it’s selection mode, we already have the ID, move forward.
            this.currentStep = "2";
        } else {
            // If it’s creation mode, we first save the Parent in Salesforce.
            this.createNewType();
        }
    }

    createNewType() {
        this.isLoading = true;
        // Prepare the record for the standard API
        const recordInput = { apiName: 'Tank_Type__c', fields: this.newTypeData };

        createRecord(recordInput)
            .then(response => {
                // Success, save the Id
                this.selectedTankTypeId = response.id;
                this.isLoading = false;
                this.showToast('Success', 'Type of Tank created: ' + this.newTypeData.Name, 'success');
                
                // Automatically advance to step 2
                this.currentStep = "2";
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error', 'The Tank Type couldnt be created: ' + error.body.message, 'error');
            });
    }

    // Step 2 Logic
    goToStep1() {
        this.currentStep = "1";
        this.parsedData = []; // Clear
    }

    handleFileUpload(event) {
        if (event.target.files.length > 0) {
            const file = event.target.files[0];
            this.isLoading = true;
            
            Papa.parse(file, {
                header: true,
                skipEmptyLines: true,
                complete: (results) => {
                    // Status by default = Available
                    const rowsWithParent = results.data.map(row => {
                        return {
                            ...row, // Copy all CSV fields
                            Tank_Type__c: this.selectedTankTypeId, // Add Parent
                            Status__c: 'Available' // Add default status
                        };
                    });

                    this.parsedData = rowsWithParent;
                    this.isLoading = false;
                    this.currentStep = "3"; // Move forward to the confirmation step.
                },
                error: (error) => {
                    this.isLoading = false;
                    this.showToast('Error', 'Error reading CSV', 'error');
                }
            });
        }
    }

    // --- Step 3 Logic

    goToStep2() {
    this.currentStep = "2";
    }
    saveData() {
        this.isLoading = true;
        
        insertTanks({ tanksToInsertList: this.parsedData })
            .then(() => {
                this.isLoading = false;
                this.showToast('Success', 'Tanks created successfullys', 'success');
                // Reset Everything
                this.currentStep = "1";
                this.parsedData = [];
                this.selectedTankTypeId = null;
            })
            .catch(error => {
                this.isLoading = false;
                let msg = error.body ? error.body.message : error.message;
                this.showToast('Error', msg, 'error');
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}