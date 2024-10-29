class PlanarArm {
    constructor(x, y, lengths, scale) {
        this.basePosition = createVector(x, y);
        this.lengths = lengths;
        this.n = lengths.length;
        this.angles = new Array(this.n).fill(0);
        this.partialSum = new Array(this.n).fill(0);
        this.scale = scale;
    }

    setAngles(angles) {
        this.angles = angles;
    }

    jacobian() {
        this.partialSum[0] = this.angles[0];

        for (let i = 1; i < this.n; i++) {
            this.partialSum[i] = this.angles[i] + this.partialSum[i - 1];
        }

        let sSum = 0;
        let cSum = 0;
        let jacArray = [[], []];

        for (let i = this.n - 1; i >= 0; i--) {
            sSum += this.lengths[i] * Math.sin(this.partialSum[i]);
            cSum += this.lengths[i] * Math.cos(this.partialSum[i]);
            jacArray[0][i] = -sSum;
            jacArray[1][i] = cSum;
        }

        return jacArray;
    }

    segment(x, y, a, l) {
        translate(x, y);
        rotate(a);
        strokeWeight(30);
        stroke(255, 160);
        line(0, 0, l, 0);
    }

    display(showEllipsoid) {
        push();

        let x = 0;
        let y = 0;
        let currentAngle = 0;

        this.segment(this.basePosition.x, this.basePosition.y, this.angles[0], this.scale * this.lengths[0]);

        for (let i = 0; i < this.n; i++) {
            currentAngle += this.angles[i];
            x += this.lengths[i] * Math.cos(currentAngle);
            y += this.lengths[i] * Math.sin(currentAngle);
            if (i > 0) {
                this.segment(this.scale * this.lengths[i - 1], 0, this.angles[i], this.scale * this.lengths[i]);
            }
        }

        pop();

        if (showEllipsoid) {
            // Perform SVD on the Jacobian matrix
            let jacobianMatrix = math.transpose(this.jacobian());
            let svd = SVDJS.SVD(jacobianMatrix);

            let uT = svd.v;
            let s = svd.q;

            let angle = Math.atan2(uT[0][1], uT[0][0]);

            push();
            strokeWeight(4);
            stroke(255, 160);
            fill(255, 0.9);
            translate(this.basePosition.x + this.scale * x, this.basePosition.y + this.scale * y);
            rotate(angle);
            ellipse(0, 0, this.scale * s[0], this.scale * s[1]); // Simplified ellipsoid with arbitrary scaling
            pop();
        }
    }
}
