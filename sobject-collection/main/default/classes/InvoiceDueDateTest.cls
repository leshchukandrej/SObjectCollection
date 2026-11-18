@IsTest
private class InvoiceDueDateTest {
    @IsTest static void thirtyDays() {
        Assert.areEqual(Date.newInstance(2026, 1, 31), InvoiceDueDate.dueDate(Date.newInstance(2026, 1, 1)));
    }
}
