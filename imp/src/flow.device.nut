pulsesPerLiter <- 5600;

pulses <- 0;
syncReady <- true;

function currentVolume() {
    return ((settings.totalVolume * pulsesPerLiter) - pulses) / pulsesPerLiter.tofloat();
}

function sync() {
    syncReady = true;
    agent.send("sync", currentVolume());
}

function onPulse() {
    pulses++;
    
    if(syncReady) {
        syncReady = false;
        imp.wakeup(1, sync);
    }
}

function onPress() { reset(); }

function reset(data) {
    pulses = data;
}

function configure(conf) {
    server.save(conf);
    settings = conf;
}

settings <- server.load();
if (settings == null) { 
    configure({ "totalVolume" : 19, "pulses" : 0 });
}

hardware.pin5.configure(DIGITAL_IN_PULLUP, onPulse);
hardware.pin7.configure(DIGITAL_IN_PULLUP, onPress);

hardware.uart12.configure(9600, 8, PARITY_NONE, 1, NO_RX);

agent.on("reset", reset);
agent.on("configure", configure);
