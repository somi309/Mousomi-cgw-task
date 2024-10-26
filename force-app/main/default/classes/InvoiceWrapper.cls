public with sharing class InvoiceWrapper {
    public Id invoiceId { get; set; }
    public String billingAccountId { get; set; }
    public Date invoiceDate { get; set; }
    public Date dueDate { get; set; }
    public List<LineItemWrapper> lineItems { get; set; }

    public class LineItemWrapper {
        public Id id { get; set; }
        public String lineDescription { get; set; }
        public Decimal quantity { get; set; }
        public Decimal unitPrice { get; set; }
        public Decimal amount{get;set;}
    
}
}