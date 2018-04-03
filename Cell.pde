// Cell object for holding grid elements.
class Cell {
    int x;
    int y;
    int ix;
    int iy;
    int s;

    boolean start = false;
    boolean end = false;
    boolean obstacle = false;

    float fScore = 0;
    float gScore = 0;
    float hScore = 0;

    Cell(int x, int y, int ix, int iy, int s) {
        this.x = x;
        this.y = y;
        this.ix = ix;
        this.iy = iy;
        this.s = s;

        // %40 chance for being obstacle.
        if (random(0, 1) < 0.4) {
            obstacle = true;
        }
    }

    // Draw the object.
    void show(int c) {
        strokeWeight(3);
        stroke(255);

        if (this.obstacle) {
            fill(120, 255);		// Block
        } else if (this.start) {
            fill(0, 0, 255);	// Start.
        } else if (this.end) {
            fill(255, 0, 125);	// End.
        } else {
            fill(255, 255, 255);
        }

        if (c == 1) {
            fill(0, 255, 0);	// Open set.
        } else if (c == 2) {
            fill(255, 0, 0);	// Closed set.
        }

        rect(x, y, s, s);		// Draw the square.
    }
}
