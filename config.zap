opt server_output = "src/server/Framework/Network.luau"
opt client_output = "src/client/Framework/Network.luau"

event PlayerStateUpdate = {
    from: Server,
	type: Reliable,
	call: SingleAsync,
    data: struct {
        Player: string,
        Index: string,
        Value: enum "Type" {
            Mana {Value: u32},
            Rebirths {Value: u32},
            Aura {Value: u32},
            Training {Value: boolean}
        }
    }
}

event UpdatePlayerPasses = {
    from: Server,
	type: Reliable,
	call: ManyAsync,
    data: struct {
        Payload: struct {
            Player: string,
            Data: struct {
                Name: string,
                Owned: boolean,
                Gifted: boolean
            }
        }[]
    }[]
}

event PlayerLeft = {
    from: Server,
	type: Reliable,
	call: ManyAsync,
    data: string
}

event RequestData = {
	from: Client,
	type: Reliable,
	call: SingleAsync
}

event RequestReplication = {
	from: Client,
	type: Reliable,
	call: SingleAsync
}