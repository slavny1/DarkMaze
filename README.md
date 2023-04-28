# DarkMaze

DarkMaze is a unique maze game designed specifically for visually impaired individuals. By utilizing haptic feedback and sound, the game provides an immersive and accessible gaming experience for those who are blind or have low vision. The objective of the game is to navigate a ball through a maze, with the ultimate goal of reaching the end.

DarkMaze was developed using a combination of the SpriteKit framework and SwiftUI View, providing a seamless and accessible navigation experience. To create the maze, the createMaze() method utilizes a 2D array, with 1 representing a path that the ball can move through and 0 representing a wall that the ball cannot pass. 

Each block in the maze is represented by a custom subclass of SKShapeNode called TileNode. The TileNode has a physics body that acts as a wall if the corresponding value in the 2D array is 0, and no physics body if the value is 1. The last tile in the maze has a physics body that represents the end of the maze.

To provide a challenging experience for players, the game includes a library of pre-defined mazes, randomly selected by the createMaze() method. In the future I want to create an algorithm which generates matrix randomly. 

During gameplay, the user receives haptic feedback and sound effects. The waving sound becomes louder as the ball gets closer to the walls, providing feedback on the ball's position. Each collision returns the ball to the initial position in the left bottom corner, and the last tile is in the top right corner.

I tested the game with the local NGO UICI for visually impaired people, and despite the app not having accessibility features, they were able to pass the maze. They encouraged me to continue working on my idea, as there are currently very few games available for blind individuals on the App Store.

DarkMaze not only provides an entertaining gaming experience but also helps to improve spatial awareness and cognitive skills for visually impaired individuals. Additionally, it promotes a sense of independence and inclusion for all players. 
