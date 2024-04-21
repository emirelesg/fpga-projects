const connectButton = document.getElementById('connect');

class Slider {
    constructor(id) {
        this.onUpdate = undefined;
        this.value = 0;
        this.sliderElement = document.getElementById(id);
        this.sliderValue = document.getElementById(`${id}-value`);

        this.update();
        this.sliderElement.addEventListener('input', () => this.update());
    }

    update() {
        this.value = this.sliderElement.value;
        this.sliderValue.innerHTML = this.value;

        if (this.onUpdate) {
            this.onUpdate();
        }
    }
}

class Radio {
    constructor(name) {
        this.onUpdate = undefined;
        this.value = 0;
        this.radioElements = document.getElementsByName(name);

        this.update();
        this.radioElements.forEach((element) => element.addEventListener('input', () => this.update()));
    }

    update() {
        this.radioElements.forEach((element) => {
            if (element.checked) {
                this.value = element.value;
            }
        })

        if (this.onUpdate) {
            this.onUpdate();
        }
    }
}

const waveSelect = new Radio('wave-type');

const adsrSliders = {
    attackMs: new Slider("attack-ms"),
    decayMs: new Slider("decay-ms"),
    sustainMs: new Slider("sustain-ms"),
    releaseMs: new Slider("release-ms"),
    sustainLevel: new Slider("sustain-level"),
}

let port;
const encoder = new TextEncoder();

const init = async () => {
    try {
        const port = await navigator.serial.requestPort();
        await port.open({ baudRate: 9600 });

        writer = port.writable.getWriter();

        const signals = await port.getSignals();
        console.log(signals);
    } catch (err) {
        console.error(err);
    }
};

const write = async (data) => {
    try {
        console.log(data);
        await writer.write(encoder.encode(data));
    } catch (err) {
        console.error(err);
    }
}

const updateAdsr = async () => {
    const adsr = Object.values(adsrSliders).map((slider) => slider.value);

    await write(`a${adsr.join(',')},`);
}

Object.values(adsrSliders).forEach((slider) => {
    slider.onUpdate = updateAdsr;
});

const updateWaveType = async () => {
    await write(`w${waveSelect.value},`);
}

waveSelect.onUpdate = updateWaveType;

// Beat

let currentBeat = 0;
const beatCheckboxes = document.querySelectorAll('.beat-checkbox');

const bpmSlider = new Slider('bpm');
const freqSliders = new Array(12).fill(0).map((_, i) => new Slider(`freq-${i + 1}`));

const updateSliders = () => {
    beatCheckboxes.forEach((beatCheckbox, i) => {
        freqSliders[i].sliderElement.disabled = !beatCheckbox.checked
    });
}

beatCheckboxes.forEach((beatCheckbox, i) => {
    beatCheckbox.addEventListener('change', () => {
        freqSliders[i].sliderElement.disabled = !beatCheckbox.checked;
    });
});

updateSliders();

const beat = async () => {
    beatCheckboxes.forEach((_, i) => {
        if (currentBeat == i) {
            beatCheckboxes[i].parentNode.classList.add('active');
        } else {
            beatCheckboxes[i].parentNode.classList.remove('active');
        }
    })

    if (beatCheckboxes[currentBeat].checked) {
        await write(`f${freqSliders[currentBeat].value},p`);
    }

    // Choose the next beat:
    // currentBeat = Math.floor(beatCheckboxes.length * Math.random());

    currentBeat += 1;
    if (currentBeat >= beatCheckboxes.length) {
        currentBeat = 0;
    }

    setTimeout(beat, 60000 / bpmSlider.value);
}

// Button Callbacks

connectButton.addEventListener('click', async () => {
    await init();
    await updateAdsr();
    await updateWaveType();
    beat(); // Start the beat!
});

const numberKeys = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8'
];

document.addEventListener("keydown", async (event) => {
    if (numberKeys.indexOf(event.key) > -1) {
        beatCheckboxes[numberKeys.indexOf(event.key)].checked = !beatCheckboxes[numberKeys.indexOf(event.key)].checked;
        updateSliders();
    }

    if (event.key === 'p') {
        await write('p');
    }
});

// Env

const envSlider = new Slider('env');

envSlider.onUpdate = async () => {
    await write(`e${envSlider.value},`);
}
