import Fgrant from 0x6d9cda4dce6218f2

    pub fun main(poolId: UInt64): &Fgrant.PoolDetails? {
        let contract = getAccount(0x6d9cda4dce6218f2).getCapability(/public/FgrantPublicP).borrow<&Fgrant.ProposalRes{Fgrant.ProposalPublic}>()!
        return contract.getPool(poolId: poolId)
    }