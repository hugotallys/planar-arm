let arm;
let n = 3; // Number of joints
let segmentLengths = []; // Lengths of arm segments
let jointAngles = []; // Angles of the joints
let noiseOffsets = []; // Noise offsets for generating smooth motion
let noiseScale = 0.005; // Perlin noise scale
let showEllipsoid = false; // To toggle the ellipsoid display

function setup() {
    createCanvas(windowWidth, windowHeight);
    initializeArm(); // Initialize the arm with the current number of joints
}

function draw() {
    background(0);

    // Update joint angles using Perlin noise
    for (let i = 0; i < n; i++) {
        jointAngles[i] = map(noise(noiseOffsets[i]), 0, 1, -PI, PI); // Angle between -PI and PI
        noiseOffsets[i] += noiseScale; // Increment the noise offset for smooth animation
    }

    // Set the angles and display the arm
    arm.setAngles(jointAngles);
    arm.display(showEllipsoid);
}

// Function to initialize the arm with current settings
function initializeArm() {
    segmentLengths = new Array(n); // Create a new array for segment lengths
    jointAngles = new Array(n); // Create a new array for joint angles
    noiseOffsets = new Array(n); // Create a new array for noise offsets

    for (let i = 0; i < n; i++) {
        segmentLengths[i] = 1.0; // Initialize segment lengths
        jointAngles[i] = 0.0; // Initialize joint angles to 0
        noiseOffsets[i] = random(1000); // Initialize noise offsets for smooth randomness
    }

    // Initialize the PlanarArm object with base position and scaling
    arm = new PlanarArm(width * 0.1, height * 0.5, segmentLengths, width * 0.05);
}
