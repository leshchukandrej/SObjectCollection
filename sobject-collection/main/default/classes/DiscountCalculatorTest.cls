@IsTest
private class DiscountCalculatorTest {
    @IsTest static void largeOrdersGetTenPercent() {
        Assert.areEqual(150, DiscountCalculator.discountFor(1500));
        Assert.areEqual(0, DiscountCalculator.discountFor(999));
    }
}
