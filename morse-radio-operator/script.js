const MORSE_MAP = {
  A: ".-", B: "-...", C: "-.-.", D: "-..", E: ".", F: "..-.", G: "--.",
  H: "....", I: "..", J: ".---", K: "-.-", L: ".-..", M: "--", N: "-.",
  O: "---", P: ".--.", Q: "--.-", R: ".-.", S: "...", T: "-", U: "..-",
  V: "...-", W: ".--", X: "-..-", Y: "-.--", Z: "--.."
};

const REVERSE_MORSE_MAP = Object.fromEntries(
  Object.entries(MORSE_MAP).map(([letter, code]) => [code, letter])
);

const MISSIONS = [
  { message: "SOS", frequency: 7100, noise: 0.32 },
  { message: "NORTH", frequency: 7035, noise: 0.36 },
  { message: "CARGO", frequency: 7180, noise: 0.28 },
  { message: "STORM", frequency: 6955, noise: 0.42 },
  { message: "LIGHT", frequency: 7240, noise: 0.31 },
  { message: "RADAR", frequency: 7310, noise: 0.34 },
  { message: "ENGINE", frequency: 6885, noise: 0.39 },
  { message: "RESCUE", frequency: 7125, noise: 0.45 },
  { message: "DOCK", frequency: 7060, noise: 0.29 },
  { message: "RETURN", frequency: 7205, noise: 0.37 }
];

const missionLabel = document.getElementById("missionLabel");
const frequencyLabel = document.getElementById("frequencyLabel");
const timerLabel = document.getElementById("timerLabel");
const scoreLabel = document.getElementById("scoreLabel");
const tuningDial = document.getElementById("tuningDial");
const signalHint = document.getElementById("signalHint");
const morseInput = document.getElementById("morseInput");
const decodedText = document.getElementById("decodedText");
const feedback = document.getElementById("feedback");
const missionLog = document.getElementById("missionLog");
const waveform = document.getElementById("waveform");
const waveCtx = waveform.getContext("2d");

let missionIndex = 0;
let totalScore = 0;
let currentInput = "";
let missionStart = performance.now();
let timerHandle = null;
let waveformSeed = 0;
let audioContext;
let gameComplete = false;

function encodeMessage(message) {
  return message
    .split(" ")
    .map((word) => word.split("").map((char) => MORSE_MAP[char]).join(" "))
    .join(" / ");
}

function decodeMorse(input) {
  return input
    .trim()
    .split(" / ")
    .map((word) => word.split(" ").map((token) => REVERSE_MORSE_MAP[token] || "?").join(""))
    .join(" ")
    .trim();
}

function getMission() {
  return MISSIONS[missionIndex];
}

function updateReadout() {
  morseInput.textContent = currentInput || "...";
  decodedText.textContent = decodeMorse(currentInput) || "...";
}

function updateTuningHint() {
  const mission = getMission();
  const dial = Number(tuningDial.value);
  const offset = Math.abs(dial - mission.frequency);

  if (offset <= 10) {
    signalHint.textContent = "Signal locked. Static is low.";
  } else if (offset <= 40) {
    signalHint.textContent = "Signal is readable, but static is still bleeding through.";
  } else {
    signalHint.textContent = "Heavy drift. Tune closer to the mission frequency.";
  }
}

function drawWaveform() {
  const mission = getMission();
  const dial = Number(tuningDial.value);
  const offset = Math.abs(dial - mission.frequency);
  const clarity = Math.max(0, 1 - offset / 180);
  const noise = mission.noise + (1 - clarity) * 0.55;
  const width = waveform.width;
  const height = waveform.height;

  waveCtx.clearRect(0, 0, width, height);
  waveCtx.fillStyle = "#061017";
  waveCtx.fillRect(0, 0, width, height);

  waveCtx.strokeStyle = "rgba(107, 224, 255, 0.22)";
  waveCtx.beginPath();
  waveCtx.moveTo(0, height / 2);
  waveCtx.lineTo(width, height / 2);
  waveCtx.stroke();

  waveCtx.strokeStyle = clarity > 0.7 ? "#7fe0a1" : "#6be0ff";
  waveCtx.lineWidth = 2;
  waveCtx.beginPath();

  for (let x = 0; x < width; x += 4) {
    const phase = (x + waveformSeed) / 22;
    const signal = Math.sin(phase) * clarity * 28;
    const staticWave = (Math.sin(phase * 2.7) + Math.cos(phase * 1.3)) * noise * 15;
    const y = height / 2 + signal + staticWave;
    if (x === 0) {
      waveCtx.moveTo(x, y);
    } else {
      waveCtx.lineTo(x, y);
    }
  }

  waveCtx.stroke();
  waveformSeed += 3;
}

function updateHeader() {
  const mission = getMission();
  if (!mission) {
    return;
  }
  missionLabel.textContent = `${missionIndex + 1} / ${MISSIONS.length}`;
  frequencyLabel.textContent = `${mission.frequency} kHz`;
  scoreLabel.textContent = String(totalScore);
  updateTuningHint();
  drawWaveform();
}

function setFeedback(text, state = "") {
  feedback.textContent = text;
  feedback.className = `feedback${state ? ` ${state}` : ""}`;
}

function resetMission(keepScore = true) {
  if (!keepScore) {
    totalScore = 0;
  }
  gameComplete = false;
  currentInput = "";
  missionStart = performance.now();
  updateReadout();
  updateHeader();
  setFeedback("Waiting for transmission.");

  if (timerHandle) {
    clearInterval(timerHandle);
  }

  timerHandle = setInterval(() => {
    const seconds = (performance.now() - missionStart) / 1000;
    timerLabel.textContent = `${seconds.toFixed(1)}s`;
    drawWaveform();
  }, 100);
}

async function ensureAudio() {
  if (!audioContext) {
    audioContext = new (window.AudioContext || window.webkitAudioContext)();
  }
  if (audioContext.state === "suspended") {
    await audioContext.resume();
  }
}

async function playSignal() {
  if (gameComplete) {
    setFeedback("All missions are complete. Restart to play again.");
    return;
  }
  await ensureAudio();
  const mission = getMission();
  const encoded = encodeMessage(mission.message);
  const dial = Number(tuningDial.value);
  const offset = Math.abs(dial - mission.frequency);
  const clarity = Math.max(0.18, 1 - offset / 180);
  const dotDuration = 0.12;
  const dashDuration = dotDuration * 3;
  const letterGap = dotDuration * 3;
  const wordGap = dotDuration * 7;
  let cursor = audioContext.currentTime + 0.05;

  function scheduleTone(duration) {
    const oscillator = audioContext.createOscillator();
    const gain = audioContext.createGain();
    oscillator.type = "sine";
    oscillator.frequency.value = 620 + clarity * 180;
    gain.gain.value = 0.001;
    oscillator.connect(gain);
    gain.connect(audioContext.destination);
    gain.gain.setValueAtTime(0.001, cursor);
    gain.gain.linearRampToValueAtTime(0.13 * clarity, cursor + 0.01);
    gain.gain.linearRampToValueAtTime(0.001, cursor + duration);
    oscillator.start(cursor);
    oscillator.stop(cursor + duration + 0.02);
    cursor += duration + dotDuration;
  }

  function scheduleNoise(duration) {
    const buffer = audioContext.createBuffer(1, Math.ceil(audioContext.sampleRate * duration), audioContext.sampleRate);
    const channel = buffer.getChannelData(0);
    for (let i = 0; i < channel.length; i += 1) {
      channel[i] = (Math.random() * 2 - 1) * mission.noise * (1.08 - clarity);
    }
    const source = audioContext.createBufferSource();
    const gain = audioContext.createGain();
    source.buffer = buffer;
    gain.gain.value = 0.035 + mission.noise * 0.05;
    source.connect(gain);
    gain.connect(audioContext.destination);
    source.start(cursor);
    cursor += duration;
  }

  for (const token of encoded) {
    if (token === ".") {
      scheduleTone(dotDuration);
    } else if (token === "-") {
      scheduleTone(dashDuration);
    } else if (token === " ") {
      scheduleNoise(letterGap);
    } else if (token === "/") {
      scheduleNoise(wordGap);
    }
  }

  setFeedback("Signal played. Decode and submit your answer.");
}

function appendInput(token) {
  currentInput += token;
  currentInput = currentInput.replace(/\s{2,}/g, " ");
  currentInput = currentInput.replace(/\s\/\s\/\s/g, " / ");
  updateReadout();
}

function normalizeMessage(text) {
  return text.replace(/\s+/g, " ").trim().toUpperCase();
}

function submitAnswer() {
  if (gameComplete) {
    setFeedback("All missions are complete. Restart to play again.");
    return;
  }
  const mission = getMission();
  const decoded = normalizeMessage(decodeMorse(currentInput));
  const expected = normalizeMessage(mission.message);
  const elapsed = Math.max(0.1, (performance.now() - missionStart) / 1000);
  const dialOffset = Math.abs(Number(tuningDial.value) - mission.frequency);
  const tuningBonus = Math.max(0, 25 - Math.floor(dialOffset / 4));

  const item = document.createElement("li");

  if (decoded === expected) {
    const missionScore = Math.max(30, Math.round(140 - elapsed * 8 + tuningBonus));
    totalScore += missionScore;
    item.textContent = `Mission ${missionIndex + 1}: ${decoded} decoded in ${elapsed.toFixed(1)}s for ${missionScore} points.`;
    setFeedback(`Correct decode: ${decoded}.`, "good");
    missionLog.appendChild(item);
    missionIndex += 1;

    if (missionIndex >= MISSIONS.length) {
      clearInterval(timerHandle);
      gameComplete = true;
      missionLabel.textContent = `${MISSIONS.length} / ${MISSIONS.length}`;
      scoreLabel.textContent = String(totalScore);
      setFeedback(`All missions complete. Final score: ${totalScore}. Press Restart Mission to replay the last mission or reload for a fresh run.`, "good");
      return;
    }

    resetMission();
    return;
  }

  item.textContent = `Mission ${missionIndex + 1}: submitted "${decoded || "?"}" instead of "${expected}".`;
  missionLog.appendChild(item);
  setFeedback(`Incorrect decode. Expected pattern does not match.`, "bad");
}

document.getElementById("playButton").addEventListener("click", playSignal);
document.getElementById("clearButton").addEventListener("click", () => {
  currentInput = "";
  updateReadout();
  setFeedback("Input cleared.");
});
document.getElementById("skipButton").addEventListener("click", () => {
  if (gameComplete) {
    missionIndex = 0;
    missionLog.innerHTML = "";
    resetMission(false);
    return;
  }
  resetMission();
});
document.getElementById("submitButton").addEventListener("click", submitAnswer);

document.querySelectorAll("[data-input]").forEach((button) => {
  button.addEventListener("click", () => appendInput(button.dataset.input));
});

tuningDial.addEventListener("input", updateHeader);

window.addEventListener("keydown", (event) => {
  if (event.key === ".") {
    appendInput(".");
  } else if (event.key === "-") {
    appendInput("-");
  } else if (event.key === " ") {
    event.preventDefault();
    appendInput(" ");
  } else if (event.key === "/") {
    appendInput(" / ");
  } else if (event.key === "Enter") {
    submitAnswer();
  }
});

resetMission(false);
