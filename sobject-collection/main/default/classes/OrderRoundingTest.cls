@IsTest
private class OrderRoundingTest {
    @IsTest static void roundsHalfUp() {
        Assert.areEqual(10.13, OrderRounding.toCents(10.125));
    }
}
