class PlanarArm {
    int n;
    float scale;
    PVector basePosition;
    float[] lengths;
    float[] angles;
    float[] partialSum;
    float[][] nullSpace;

    PlanarArm(float x, float y, float[] lengths, float scale) {
        this.basePosition = new PVector(x, y);
        this.lengths = lengths;
        this.n = lengths.length;
        this.angles = new float[n];
        this.partialSum = new float[n];
        this.scale = scale;
        this.nullSpace = new float[n][n - 2];
    }

    void setAngles(float[] angles) {
        this.angles = angles;
    }

    SimpleMatrix jacobian() {
        partialSum[0] = angles[0];
        
        for (int i = 1; i < n; i++) {
            partialSum[i] = angles[i] + partialSum[i - 1];
        }

        float sSum = 0;
        float cSum = 0;
        float[][] jacArray = new float[2][n];

        for (int i = n - 1; i >= 0; i--) {
            sSum += lengths[i] * Math.sin(partialSum[i]);
            cSum += lengths[i] * Math.cos(partialSum[i]);
            jacArray[0][i] = -sSum;
            jacArray[1][i] = cSum;
        }

        return new SimpleMatrix(jacArray);
    }

    void segment(float x, float y, float a, float l) {
        translate(x, y);
        rotate(a);
        strokeWeight(30);
        stroke(255, 160);
        line(0, 0, l, 0);
    }

    void display(boolean showEllipsoid) {
        pushMatrix();

        float x = 0;
        float y = 0;
        float currentAngle = 0;

        segment(basePosition.x, basePosition.y, angles[0], scale * lengths[0]);

        for (int i = 0; i < n; i++) {
            currentAngle += angles[i];
            x += lengths[i] * Math.cos(currentAngle);
            y += lengths[i] * Math.sin(currentAngle);
            if (i > 0) {
                segment(scale * lengths[i - 1], 0, angles[i], scale * lengths[i]);
            }
        }

        popMatrix();

        SimpleSVD<SimpleMatrix> svd = jacobian().svd();
        SimpleMatrix uT = svd.getU().transpose();
        SimpleMatrix s = svd.getW();
        SimpleMatrix nullSpace = svd.nullSpace();

        for (int i = 0; i < n - 2; i++) {
            for (int j = 0; j < n; j++) {
                this.nullSpace[j][i] = (float) nullSpace.get(j, i);
            }
        }

        float angle = (float) Math.atan2(uT.get(0, 1), uT.get(0, 0));

        if (showEllipsoid) {
            pushMatrix();
            strokeWeight(4);
            fill(255, 0);
            translate(basePosition.x + scale * x, basePosition.y + scale * y);
            rotate(angle);
            ellipse(0, 0, scale * (float) s.get(0, 0), scale * (float) s.get(1, 1));
            popMatrix();
        }
    }
}
