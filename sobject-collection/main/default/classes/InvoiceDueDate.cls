public with sharing class InvoiceDueDate {
    public static Date dueDate(Date issued) {
        return issued.addDays(30);
    }
}
