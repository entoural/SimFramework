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
            Rebirths {Value: u32},
            Cash {Value: u32},
            Boost {Value: u32},
            RecordScore {Value: u32},
            Floors {Value: u16},
            RocketLevel {Value: u8},
            Rocket {Value: string},
            BuildingModel {Value: Instance (Model)?},
            InLaunch {Value: boolean}
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

event StatEffect = {
    from: Server,
	type: Reliable,
	call: ManyAsync,
    data: struct {
        Stat: string,
        Amount: u8
    }
}

event RequestData = {
	from: Client,
	type: Reliable,
	call: SingleAsync
}

event ChangeFloors = {
	from: Client,
	type: Reliable,
	call: ManyAsync,
    data: u16
}

event RejoinRound = {
	from: Client,
	type: Reliable,
	call: SingleAsync
}

event LaunchPlayer = {
    from: Server,
	type: Reliable,
	call: ManyAsync,
    data: struct {
        LaunchData: struct {
            MaxHeightIncrease: f32,
            Gravity: f32,
            HorizontalSpeed: f32,
            SpeedMultiplier: f32
        },
        Accuracy: f32
    }
}

event RequestLaunch = {
    from: Client,
	type: Reliable,
	call: ManyAsync,
    data: f32(..1)
}

event UpgradeLevel = {
    from: Client,
	type: Reliable,
	call: ManyAsync
}

event Rebirth = {
    from: Client,
	type: Reliable,
	call: ManyAsync
}

event BuyNextRocket = {
    from: Client,
	type: Reliable,
	call: ManyAsync
}

event BuyNextFloor = {
    from: Client,
	type: Reliable,
	call: ManyAsync
}

event RequestReplication = {
	from: Client,
	type: Reliable,
	call: SingleAsync
}