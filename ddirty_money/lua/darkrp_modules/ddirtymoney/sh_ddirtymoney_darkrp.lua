TEAM_LAUNDERGUY = DarkRP.createJob("Launder Guy", {
    color = Color(0, 128, 255, 255),
    model = {"models/player/group01/male_02.mdl"},
    description = [[Players come see you to make business]],
    weapons = {},
    command = "launderguy",
    max = 1,
    salary = 200,
    admin = 0,
    vote = false,
    hasLicense = false
})

DarkRP.createCategory{
    name = "Launder",
    categorises = "entities",
    startExpanded = true,
    color = Color(255, 150, 150, 255),
    canSee = function(ply) return true end,
    sortOrder = 100
}

DarkRP.createEntity("Monitor", {
    ent = "ddirtymoney_monitor",
    model = "models/props/cs_office/computer_monitor.mdl",
    price = 250,
    max = 1,
    cmd = "buydirtymoneymonitor",
    allowed = TEAM_LAUNDERGUY,
    category = "Launder"
})