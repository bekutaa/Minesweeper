import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import de.bezier.guido.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Minesweeper extends PApplet {


//Declare and initialize NUM_ROWS and NUM_COLS = 20
public static final int NUM_COLS = 20;
public static final int NUM_ROWS = 20;

private MSButton[][] buttons; //2d array of minesweeper buttons
private ArrayList <MSButton> bombs; //ArrayList of just the minesweeper buttons that are mined

public void setup ()
{
    size(400, 400);
    textAlign(CENTER,CENTER);
    
    // make the manager
    Interactive.make( this );

    //declare and initialize buttons
    buttons = new MSButton [NUM_ROWS][NUM_COLS];

    for(int i = 0; i < NUM_ROWS; i++)
    {
        for(int n = 0; n < NUM_COLS; n++)
        {
            buttons[i][n] = new MSButton(i,n);
        }
    }

    bombs = new ArrayList <MSButton>();
    setBombs(15);
}
public void setBombs(int numBombs)
{
    for(int i = 0; i < numBombs; i++)
    {
        int tRow = (int)(Math.random()*20);
        int tCol = (int)(Math.random()*20);

        if(bombs.contains(buttons[tRow][tCol]) == false)
        {
            bombs.add(buttons[tRow][tCol]);
        }
        else { i--; }
    }
}

public void keyPressed()
{
    if(key == ' ')
    {
        for(int r = 0; r < NUM_ROWS; r++)
        {
            for(int c = 0; c < NUM_COLS; c++)
            {
                buttons[r][c].setMarked(true);
            }
        }
    }
}

public void draw ()
{
    background( 0 );
    if(isWon())
        displayWinningMessage();
}
public boolean isWon()
{
    return false;
}
public void displayLosingMessage()
{
    System.out.println("This is a LOSING message.");
    noLoop();
}
public void displayWinningMessage()
{
    System.out.println("This is a WINNING message.");
    noLoop();
}

public class MSButton
{
    private int r, c;
    private float x,y, width, height;
    private boolean clicked, marked;
    private String label;
    
    public MSButton ( int rr, int cc )
    {
        width = 400/NUM_COLS;
        height = 400/NUM_ROWS;
        r = rr;
        c = cc; 
        x = c*width;
        y = r*height;
        label = "";
        marked = clicked = false;
        Interactive.add( this ); // register it with the manager
    }
    public boolean isMarked()
    {
        return marked;
    }

    public void setMarked(boolean nMark)
    {
        marked = nMark;
    }
    public boolean isClicked()
    {
        return clicked;
    }
    
    // called by manager
    public void mousePressed () 
    {
        // if(!clicked)
        // {
        //     if(mouseButton == RIGHT) { marked = !marked; }
        //     else if(!marked) { clicked = true; }
        // }
        clicked = !marked;
        if(mouseButton == RIGHT)  { marked = !marked; }
        else if(bombs.contains(this)) { displayLosingMessage(); }
        else if(countBombs(r,c) > 0) { setLabel("" + countBombs(r,c)); }
        else {
            for(int rr = -1; rr < 2; rr++)
            {
                for(int cc = -1; cc < 2; cc++)
                {
                    if(isValid(r+rr,c+cc) && buttons[r+rr][c+cc].isClicked() == false)
                    {
                        buttons[r+rr][c+cc].mousePressed();
                    }
                }
            }
        }
        //call mousepressed with valid neighboring unclicked buttons
        // else { setLabel("" + countBombs(r,c)); }
    }

    public void draw () 
    {    
        if (marked)
            fill(0);
        else if( clicked && bombs.contains(this) ) 
            fill(255,0,0);
        else if(clicked)
            fill( 200 );
        else 
            fill( 100 );

        stroke(0,255,0);
        rect(x, y, width, height);
        fill(0);
        text(label,x+width/2,y+height/2);
    }

    public void setLabel(String newLabel)
    {
        label = newLabel;
    }

    public boolean isValid(int r, int c)
    {
        if(r >= 0 && r < NUM_ROWS && c >= 0 && c < NUM_COLS) { return true; }
        return false;
    }

    public int countBombs(int row, int col)
    {
        int numBombs = 0;
        
        for(int rr = -1; rr < 2; rr++)
        {
            for(int cc = -1; cc < 2; cc++)
            {
                if(isValid(row+rr,col+cc) && bombs.contains(buttons[row+rr][col+cc]))
                {
                    numBombs++;
                }
            }
        }

        return numBombs;
    }
}



  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Minesweeper" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
