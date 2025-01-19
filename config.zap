opt server_output = "src/server/Framework/Network.luau"
opt client_output = "src/client/Framework/Network.luau"

event PlayerStateUpdate = {
    from: Server,
	type: Reliable,
	call: SingleAsync,
    data: struct {
        Player: string?,
        Index: string,
        Value: enum "Type" {
            Wins {Value: u32},
            Cash {Value: u32},
            PlayedRound {Value: boolean},
            RoundState {Value: struct {
                State: string,
                Num1: u16?,
                Num2: u16?
            }},
            Winners {Value: string[]},
            ShowingTiles {Value: Instance[]},
            InRound {Value: boolean}
        }
    }
}

event UpdatePlayerPasses = {
    from: Server,
	type: Reliable,
	call: ManyAsync,
    data: struct {
        Player: string,
        Data: struct {
            Name: string,
            Owned: boolean,
            Gifted: boolean
        }
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

event RejoinRound = {
	from: Client,
	type: Reliable,
	call: SingleAsync
}

event RequestReplication = {
	from: Client,
	type: Reliable,
	call: SingleAsync
}