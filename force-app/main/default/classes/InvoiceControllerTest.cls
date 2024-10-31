@IsTest
public class InvoiceControllerTest {

    @TestSetup
    static void setupTestData() {
        // Create test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create test Opportunity
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            CloseDate = Date.today().addDays(10),
            StageName = 'Prospecting'
        );
        insert testOpportunity;

        // Create Opportunity Product (OpportunityLineItem) records
        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
        insert testProduct;

        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        
        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pricebookEntry;

        OpportunityLineItem opportunityLineItem = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            Quantity = 2,
            UnitPrice = 100,
            PricebookEntryId = pricebookEntry.Id
        );
        insert opportunityLineItem;
    }

    @IsTest
    static void testCreateInvoiceAndLineItems() {
        // Retrieve test Opportunity and OpportunityLineItem data
        Opportunity testOpportunity = [SELECT Id, AccountId, CloseDate FROM Opportunity LIMIT 1];
        OpportunityLineItem testLineItem = [SELECT Id, Quantity, UnitPrice FROM OpportunityLineItem WHERE OpportunityId = :testOpportunity.Id LIMIT 1];

        // Prepare parameters to simulate URL parameters in JSON
        Map<String, String> params = new Map<String, String>();
        params.put('origin_record', testOpportunity.Id);
        params.put('account', testOpportunity.AccountId);
        params.put('invoice_date', String.valueOf(testOpportunity.CloseDate));
        params.put('invoice_due_date', String.valueOf(Date.today().addDays(30)));  // Assuming a due date 30 days from today
        params.put('child_relationship_name', 'OpportunityLineItems');
        params.put('line_item_description', 'Product2.Name');
        params.put('line_item_quantity', 'Quantity');
        params.put('line_item_unit_price', 'UnitPrice');

        // Serialize the map to JSON to pass to the method
        String paramsJson = JSON.serialize(params);

        Test.startTest();
        
        // Call the method in InvoiceController
        String resultJson = InvoiceController.createInvoiceAndLineItems(paramsJson);
        
        Test.stopTest();

        // Parse the JSON result to verify Invoice and Line Item creation
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(resultJson);
        
        // Check that Invoice is created and has correct fields
        Invoice__c createdInvoice = (Invoice__c) resultMap.get('Invoice');
        System.assertNotEquals(null, createdInvoice, 'Invoice should be created.');
        System.assertEquals(testOpportunity.Id, createdInvoice.Opportunity__c, 'Invoice should be linked to the Opportunity.');
        System.assertEquals(testOpportunity.AccountId, createdInvoice.Account__c, 'Invoice should be linked to the correct Account.');

        // Check that Line Items are created and associated with the Invoice
        List<Object> createdLineItems = (List<Object>) resultMap.get('LineItems');
        System.assertEquals(1, createdLineItems.size(), 'One Line Item should be created.');
        
        Map<String, Object> lineItemData
