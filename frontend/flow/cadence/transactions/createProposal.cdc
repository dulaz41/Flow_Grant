import FGrant from f8d6e0586b0a20c7

transaction {

    prepare(acct: AuthAccount) {

        let proposalResource <- acct.load<@FGrant.Proposal>(from: /storage/FGrant)
        let poolResource <- acct.load<@FGrant.Pool>(from: /storage/FGrant)

        log(proposalResource?.details)
        log(poolResource?.details)

        acct.save(<-proposalResource!, to: /storage/FGrant)
        acct.save(<-poolResource!, to: /storage/FGrant)
    }

    execute(){
        
    }
}