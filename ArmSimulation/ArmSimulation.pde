import controlP5.*;
import java.util.ArrayList;

PlanarArm arm;
ControlP5 cp5;
int n = 3;

float[] segmentLengths;
float[] jointAngles;
float[] noiseOffsets;
float noiseScale = 0.005;

ArrayList<Numberbox> lengthBoxes = new ArrayList<>();
ArrayList<Numberbox> angleBoxes = new ArrayList<>();

String[] updateLogicArray = new String[]{"Manual", "Null Space", "Random"};
int updateLogic = 0;

boolean showEllipsoid = false;

void setup() {
    size(1280, 720);
    cp5 = new ControlP5(this);
    setupSlider();
    setupLengthBoxes();
    setupAngleBoxes();
    setupEllipsoidToggle();
    setupDropdownList();
    initializeArm();
}

void draw() {
    background(0);

    if (updateLogic == 0) {
        for (int i = 0; i < n; i++) {
            jointAngles[i] = angleBoxes.get(i).getValue();
        }
    } else if (updateLogic == 1) {
        for (int i = 0; i < n - 2; i++) {
            for (int j = 0; j < n; j++) {
                jointAngles[j] += 0.01 * arm.nullSpace[j][i];
            }
        }
    } else if (updateLogic == 2) {
        for (int i = 0; i < n; i++) {
            jointAngles[i] = map(noise(noiseOffsets[i]), 0, 1, -0.8 * PI, 0.8 * PI);
            noiseOffsets[i] += noiseScale;
        }
    }

    arm.setAngles(jointAngles);
    arm.display(showEllipsoid);
}

void initializeArm() {
    segmentLengths = new float[n];
    jointAngles = new float[n];
    noiseOffsets = new float[n];

    for (int i = 0; i < n; i++) {
        segmentLengths[i] = 1.0f;
        jointAngles[i] = 0.0f;
        noiseOffsets[i] = random(1000);
    }

    arm = new PlanarArm(width * 0.1, height * 0.5, segmentLengths, width * 0.1);
    updateLengthBoxes();
    updateAngleBoxes();
}

void setupSlider() {
    cp5.addLabel("Planar Arm Simulation")
        .setPosition(width - 380, 10)
        .setSize(280, 20)
        .setFont(createFont("Arial", 16))
        .setColor(255);

    cp5.addSlider("Number of Joints")
        .setPosition(width - 380, 40)
        .setSize(280, 40)
        .setRange(2, 5)
        .setValue(n)
        .setNumberOfTickMarks(4)
        .setSliderMode(Slider.FLEXIBLE)
        .setTriggerEvent(Slider.RELEASED)
        .addListener(new ControlListener() {
            public void controlEvent(ControlEvent event) {
                n = (int) event.getValue();
                initializeArm();
            }
        });
}

void setupLengthBoxes() {
    cp5.addLabel("Arm Length")
        .setPosition(width - 380, 100)
        .setSize(280, 20)
        .setFont(createFont("Arial", 16))
        .setColor(255);

    for (int i = 0; i < 5; i++) {
        Numberbox nb = cp5.addNumberbox("Length " + (i + 1))
            .setPosition(width - 380, 130 + i * 50)
            .setSize(100, 30)
            .setRange(0.5, 2.0)
            .setValue(1.0f)
            .setVisible(i < n)
            .addListener(new ControlListener() {
                public void controlEvent(ControlEvent event) {
                    int index = Integer.parseInt(event.getName().split(" ")[1]) - 1;
                    segmentLengths[index] = event.getValue();
                }
            });
        lengthBoxes.add(nb);
    }
}

void setupAngleBoxes() {
    cp5.addLabel("Joint Angles")
        .setPosition(width - 250, 100)
        .setSize(280, 20)
        .setFont(createFont("Arial", 16))
        .setColor(255);

    for (int i = 0; i < 5; i++) {
        Numberbox nb = cp5.addNumberbox("Angle " + (i + 1))
            .setPosition(width - 250, 130 + i * 50)
            .setSize(100, 30)
            .setRange(-PI, PI)
            .setValue(0.0f)
            .setVisible(i < n)
            .addListener(new ControlListener() {
                public void controlEvent(ControlEvent event) {
                    int index = Integer.parseInt(event.getName().split(" ")[1]) - 1;
                    jointAngles[index] = event.getValue();
                }
            });
        angleBoxes.add(nb);
    }
}

void setupEllipsoidToggle() {
    cp5.addLabel("Manipulability Ellipsoid")
        .setPosition(width - 380, 380)
        .setSize(280, 20)
        .setFont(createFont("Arial", 16))
        .setColor(255);

    cp5.addToggle("Show Ellipsoid")
        .setPosition(width - 250, 380)
        .setSize(100, 30)
        .setValue(false)
        .setMode(ControlP5.SWITCH)
        .setLabel("Show / Hide")
        .addListener(new ControlListener() {
            public void controlEvent(ControlEvent event) {
                showEllipsoid = event.getController().getValue() == 1;
            }
        });
}

void setupDropdownList() {
    cp5.addLabel("Control Mode")
        .setPosition(width - 380, 455)
        .setSize(280, 20)
        .setFont(createFont("Arial", 16))
        .setColor(255);

    cp5.addScrollableList("Update Logic")
        .setPosition(width - 250, 450)
        .setSize(150, 100)
        .setBarHeight(30)
        .setItemHeight(20)
        .addItems(updateLogicArray)
        .setValue(0)
        .setOpen(false)
        .addListener(new ControlListener() {
            public void controlEvent(ControlEvent event) {
                updateLogic = (int) event.getValue();
                boolean manualMode = updateLogic == 0;
                for (int i = 0; i < n; i++) {
                    angleBoxes.get(i).setVisible(manualMode);
                }
            }
        });
}

void updateLengthBoxes() {
    for (int i = 0; i < lengthBoxes.size(); i++) {
        if (i < n) {
            lengthBoxes.get(i).setVisible(true);
            lengthBoxes.get(i).setValue(segmentLengths[i]);
        } else {
            lengthBoxes.get(i).setVisible(false);
        }
    }
}

void updateAngleBoxes() {
    for (int i = 0; i < angleBoxes.size(); i++) {
        if (i < n && updateLogic == 0) {
            angleBoxes.get(i).setVisible(true);
            angleBoxes.get(i).setValue(jointAngles[i]);
        } else {
            angleBoxes.get(i).setVisible(false);
        }
    }
}
