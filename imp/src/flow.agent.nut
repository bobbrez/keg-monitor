#require "PubNub.class.nut:1.1.0"

settings <- server.load();
pubNub <- PubNub("pub-c-65c69104-35f5-42f3-a2fd-5b3eac654653", "sub-c-24c7195a-cd55-11e5-a9aa-02ee2ddab7fe");
currentVolume <- 0;

function buildData() {
    return { "keg0" : { 
        "currentVolume" : currentVolume, 
        "totalVolume" : settings.totalVolume 
    } };
}

function publish() {
    local data = buildData();
    pubNub.publish("my_channel", data);
}

function onDeviceSync(volume) {
    currentVolume = volume;
    publish();
}

function reset(request, response) {
    currentVolume = settings.totalVolume;
    device.send("reset", 0);
    publish();
    response.send(204, "");
}

function get(request, response) {
    local data = buildData();
    
    response.header("Content-Type", "application/json");
    response.header("Access-Control-Allow-Origin", "*");

    return response.send(200, http.jsonencode(data));
}

function update(request, response) {
    settings = http.jsondecode(request.body);
    configure(settings);

    response.header("Content-Type", "application/json");
    response.send(200, http.jsonencode(settings));
}

function requestHandler(request, response) {
    switch(request.method) {
        case "DELETE":
            return reset(request, response);
        case "GET":
            return get(request, response);
        case "PATCH":
            return update(request, response);
        default:
            return response.send(404, "Method");
    };
}

function configure(conf) {
    server.save(settings);
    device.send("configure", settings);
}

if (settings == null) { configure({ "totalVolume" : 19 }); }

device.on("sync", onDeviceSync);
http.onrequest(requestHandler);
