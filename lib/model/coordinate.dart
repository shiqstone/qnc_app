
class Coordinate {
	late double x;
	late double y;
  
	Coordinate(this.x, this.y);
  
	Map toJson() => {
		  'x': x,
		  'y': y,
		};
  }