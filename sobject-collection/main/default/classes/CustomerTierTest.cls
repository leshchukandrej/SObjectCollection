@IsTest
private class CustomerTierTest {
    @IsTest static void tiersFollowSpend() {
        Assert.areEqual('Gold', CustomerTier.tierFor(60000));
        Assert.areEqual('Silver', CustomerTier.tierFor(12000));
        Assert.areEqual('Bronze', CustomerTier.tierFor(500));
    }
}
