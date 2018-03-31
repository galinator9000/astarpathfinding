// 2D Cell object array for holding all cell objects.
Cell[][] Cells;

int rows;			// Count of rows.
int cols;			// Count of columns.
int res = 20;

int startX;		// Starting XY point.
int startY;

int curX = 0;	// Current XY point
int curY = 0;

float tempG;	// Temporary variables for holding F and G values.
float tempF;
int winner;		// Winner index on openset.

Cell current;	// Current cell object.
Cell end;		// End cell object.

Cell[] neighbors;	// Cell array for holding neighbors.
Cell neighbor;		// Single neighbor. (Temporary)

Cell[] openSet;		// OpenSet array for holding Cell objects which should be evaluated.
Cell[] closedSet;	// ClosedSet array for holding Cell objects which already evaluated and should be ignored.

void setup(){
	size(800, 800);		// Keep window size square if possible.

	rows = height / res;	// Calculating rows and columns count.
	cols = width / res;

	Cells = new Cell[rows][cols];
	neighbors = new Cell[8];	// There are 8 neighbors.

	openSet = new Cell[rows*cols];
	closedSet = new Cell[rows*cols];

	startX = 0;
	startY = 0;
	curX = startX;
    curY = startY;

	// Creating cell objects.
	for(int r=0; r<rows; r++){
		for(int c=0; c<cols; c++){
			Cells[r][c] = new Cell(r*res, c*res, r, c, res);
		}
	}
	
	current = Cells[curX][curY];	// Current cell object.	(Left top.)
	end = Cells[rows-1][cols-1];	// End object.	(Bottom right.)

	// Start and End cell objects shouldn't be obstacles.
	current.start = true;
	current.obstacle = false;

    end.end = true;
	end.obstacle = false;

	PushCell(openSet, current);		// Push first cell to the OpenSet.
	current.fScore = heuristic(current, end);	// First f score is just heuristic from start -> end.
}

void draw(){
	background(30);

	// Is there any objects in OpenSet? If it is we should continue.
	if(NonNullArray(openSet)){
		winner = 0;

		// Pick the most efficient one in OpenSet. Their values already calculated before pushing on array.
		for(int o=0; o<openSet.length; o++){
			if(openSet[o] != null){
				if(openSet[o].fScore < openSet[winner].fScore){
					winner = o;
				}
			}
		}
		current = openSet[winner];		// We take a step to most efficient cell.
		curX = current.ix;
        curY = current.iy;
		PushCell(closedSet, current);	// Remove ourselves from OpenSet, and adding to ClosedSet.
        RemoveCell(openSet, current);	// We evaluated this point.

		// Are we at End cell? We're DONE!
        if(current == end){
            noLoop();
            println("DONE!");
            drawCells();
            return;
        }

		// Check our neighbors.
		checkNeighbors();
		for(int n=0; n<neighbors.length; n++){
			if(neighbors[n] != null){
				neighbor = neighbors[n];
				if(!arrayContains(closedSet, neighbor)){		// Is this neighbor on ClosedSet?
					if(!arrayContains(openSet, neighbor)){		// Is this neighbor on OpenSet?
						PushCell(openSet, neighbor);			// If it is not in there, push it. We should evaluate it.
					}

					neighbor.gScore = current.gScore + 1;			// Calculate score for that neighbor. f = g + h
					neighbor.hScore = heuristic(neighbor, end);
					neighbor.fScore = neighbor.gScore + neighbor.hScore;
				}
			}
		}
	// Aren't there any objects in OpenSet? There is no solution.
	}else{
		noLoop();
		println("No solution :(");
		drawCells();
		return;
	}

	drawCells();
}

// Heuristic calculation. Take raw distance.
float heuristic(Cell a, Cell b){
	return dist(a.x, a.y, b.x, b.y);
}

// Draw all cells in grid.
void drawCells(){
	for(int r=0; r<rows; r++){
        for(int c=0; c<cols; c++){
            Cells[r][c].show(0);
        }
    }

    for(int c=0; c<openSet.length; c++){
		if(openSet[c] != null){
			openSet[c].show(1);
		}
    }
	for(int c=0; c<closedSet.length; c++){
        if(closedSet[c] != null){
            closedSet[c].show(2);
        }
    }
}

// Check neighbors.
// Top, TopRight, Right, BottomRight, Bottom, BottomLeft, Left, TopLeft

/*

Starting from top and goes on clockwise.

N    N    N

N    c    N

N    N    N
*/

boolean checkNeighbors(){
    boolean availableNeighbors;

    for(int n=0; n<neighbors.length; n++){
        neighbors[n] = null;
    }

    availableNeighbors = false;
    if(curY-1 > 0){
        if(!Cells[curX][curY-1].obstacle){
            neighbors[0] = Cells[curX][curY-1];		// Top neighbor
            availableNeighbors = true;
        }
    }
	if(curY-1 > -1 && curX+1 < rows){
        if(!Cells[curX+1][curY-1].obstacle){
            neighbors[1] = Cells[curX+1][curY-1];    // Top Right neighbor
            availableNeighbors = true;
        }
    }
    if(curX+1 < rows){
        if(!Cells[curX+1][curY].obstacle){
            neighbors[2] = Cells[curX+1][curY];		// Right neighbor
            availableNeighbors = true;
        }
    }
	if(curX+1 < rows && curY+1 < cols){
        if(!Cells[curX+1][curY+1].obstacle){
            neighbors[3] = Cells[curX+1][curY+1];    // Bottom Right neighbor
            availableNeighbors = true;
        }
    }
    if(curY+1 < cols){
        if(!Cells[curX][curY+1].obstacle){
            neighbors[4] = Cells[curX][curY+1];		// Bottom neighbor
            availableNeighbors = true;
        }
    }
	if(curX-1 > -1 && curY+1 < cols){
        if(!Cells[curX-1][curY+1].obstacle){
            neighbors[5] = Cells[curX-1][curY+1];    // Bottom Left neighbor
            availableNeighbors = true;
        }
    }
    if(curX-1 > 0){
        if(!Cells[curX-1][curY].obstacle){
            neighbors[6] = Cells[curX-1][curY];		// Left neighbor
            availableNeighbors = true;
        }
    }
	if(curX-1 > -1 && curY-1 > -1){
        if(!Cells[curX-1][curY-1].obstacle){
            neighbors[7] = Cells[curX-1][curY-1];	// Top Left neighbor
            availableNeighbors = true;
        }
    }

    return availableNeighbors;
}

// Pop cell object from array.
Cell PopCell(Cell[] Stack){
    int i = StackAvailable(Stack);
    Cell r;

    if(i != -1 && i != 0){
        r = Stack[i-1];
        Stack[i-1] = null;
        return r;
    }
    return null;
}

// Is whole array filled with nulls?
boolean NonNullArray(Cell[] arr){
	for(int e=0; e<arr.length; e++){
		if(arr[e] != null){		// We found non-null element.
			return true;
		}
	}
	return false;
}

// Remove cell object from stack.
boolean RemoveCell(Cell[] Stack, Cell cell){
    for(int c=0; c<Stack.length; c++){
		if(Stack[c] == cell){		// We found the requested object.
			Stack[c] = null;

			for(int cc=c+1; cc<Stack.length; cc++){		// Slide array to left side.
				Stack[cc-1] = Stack[cc];				// We removed 1 element. We should keep it as stack for doing well. 
			}
			return true;
		}
	}
	return false;
}

// Push cell object to stack.
void PushCell(Cell[] Stack, Cell cell){
    int i = StackAvailable(Stack);

    if(i != -1){
        Stack[i] = cell;
    }
}

// Check stack's last available spot.
int StackAvailable(Cell[] Stack){
    for(int s=0; s<Stack.length; s++){
        if(Stack[s] == null){
            return s;
        }
    }
    return -1;
}

// Is this array contains this element?
boolean arrayContains(Cell[] arr, Cell elm){
	for(int i=0; i<arr.length; i++){
		if(arr[i] == elm){
			return true;
		}
	}
	return false;
}
