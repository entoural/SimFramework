opt server_output = "src/server/Framework/Network.luau"
opt client_output = "src/client/Framework/Network.luau"

event PlayerStateUpdate = {
    from: Server,
	type: Reliable,
	call: SingleAsync,
    data: struct {
        Player: Instance (Player),
        Index: string,
        Value: enum "Type" {
            Cash {value: u32}
        }
    }
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