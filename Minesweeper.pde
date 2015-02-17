import de.bezier.guido.*;
//Declare and initialize NUM_ROWS and NUM_COLS = 20
public static final int NUM_COLS = 20; //40;
public static final int NUM_ROWS = 20; //NUM_COLS-(int)(NUM_COLS/4);

//public static final int BUTTON_WIDTH = 20;
//public static final int BUTTON_HEIGHT = 20;

public boolean bombsSet = false;
public boolean gameOver = false;

//public static final int NUM_BOMBS = (int)((NUM_ROWS*NUM_COLS)*0.1);
public static final int NUM_BOMBS = 40;

private MSButton[][] buttons; //2d array of minesweeper buttons
private ArrayList <MSButton> bombs; //ArrayList of just the minesweeper buttons that are mined

void setup()
{
    size(400,400);
    //size(NUM_COLS*BUTTON_WIDTH + 1, NUM_ROWS*BUTTON_HEIGHT + 1);
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
}
public void setBombs(int numBombs, int rr, int cc)
{
    for(int i = 0; i < numBombs; i++)
    {
        int tRow = (int)(Math.random()*NUM_ROWS);
        int tCol = (int)(Math.random()*NUM_COLS);

        if(bombs.contains(buttons[tRow][tCol]) == false && tRow != rr && tCol != cc)
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
    bombsSet = false;
    gameOver = false;
    for(int i = 0; i < NUM_BOMBS; i++) {
      if(bombs.size() > 0) {
        bombs.remove(0);
      }
    }
    for(int rr = 0; rr < NUM_ROWS; rr++)
    {
      for(int cc = 0; cc < NUM_COLS; cc++)
      {
        buttons[rr][cc].setClicked(false);
        buttons[rr][cc].setMarked(false);
        buttons[rr][cc].setLabel("");
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
    int countM = 0;
    int countC = 0;
    for(int r = 0; r < NUM_ROWS; r++)
    {
        for(int c = 0; c < NUM_COLS; c++)
        {
            if(buttons[r][c].isMarked()) {
                countM++;
            }
            else if(buttons[r][c].isClicked()) {
                countC++;
            }
        }
    }
    int countB = 0;
    for(int i = 0; i < bombs.size(); i++)
    {
        if((bombs.get(i)).isMarked()) {
            countB++;
        }
    }
    if( (countB == NUM_BOMBS && countM + countC == NUM_ROWS*NUM_COLS && countB == countM) || NUM_BOMBS == (NUM_ROWS*NUM_COLS)-countC ) {
        return true;
    }

    return false;
}
public void displayLosingMessage()
{
    for(int i = 0; i < bombs.size(); i++)
    {
        (bombs.get(i)).setClicked(true);
        (bombs.get(i)).setMarked(false);
        (bombs.get(i)).setLabel("B");
    }

    int row = (NUM_ROWS/2)-1;
    int col = (NUM_COLS/4)+1;
    String loser = "You lose!";

    for(int i = 0; i < loser.length(); i++)
        buttons[row][col+i].setLabel(loser.substring(i,i+1));
}
public void displayWinningMessage()
{
  for(int a = 0; a < bombs.size(); a++)
    (bombs.get(a)).setMarked(true);
  int row = (NUM_ROWS/2)-1;
  int col = (NUM_COLS/4)+1;
  String winner = "You win!";

  for(int i = 0; i < winner.length(); i++)
    if(col+i < NUM_COLS)
        buttons[row][col+i].setLabel(winner.substring(i,i+1));
}

public class MSButton
{
    private int r, c;
    private float x,y, width, height;
    private boolean clicked, marked;
    private String label;
    
    public MSButton ( int rr, int cc )
    {
        width = 20;//BUTTON_WIDTH;
        height = 20;//BUTTON_HEIGHT;
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

    public void setClicked(boolean nClick)
    {
        clicked = nClick;
    }
    
    //called by manager
    public void mousePressed()
    {
        if(!bombsSet)
        {
            bombsSet = true;
            setBombs(NUM_BOMBS,r,c);
        }

        if(!isWon() && !gameOver) { 
            if(mouseButton == RIGHT && label.equals(""))
            {
                if(bombs.contains(this)) {
                    clicked = false;
                    marked = !marked;
                }
                else if(clicked == false) {
                    clicked = false;
                    marked = !marked;
                }
            }
            else if(mouseButton == CENTER)
            {
                
                if(countMarks(r,c) == Integer.parseInt(label))
                {
                    for(int rr = -1; rr < 2; rr++)
                    {
                        for(int cc = -1; cc < 2; cc++)
                        {
                            if(isValid(r+rr,c+cc))
                            {
                                buttons[r+rr][c+cc].mouseSurround();
                            }
                        }
                    }
                }
            }
            else if(!marked)
            {
                clicked = true;
                if(bombs.contains(this))
                {
                    gameOver = true;
                    displayLosingMessage();
                }
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
            }
        }
    }

    public void mouseSurround()
    {
        if(!marked && !clicked)
        {
            clicked = true;
            if(bombs.contains(this)) { displayLosingMessage(); }
            else if(countBombs(r,c) > 0) { setLabel("" + countBombs(r,c)); }
            else {
                for(int rr = -1; rr < 2; rr++)
                {
                    for(int cc = -1; cc < 2; cc++)
                    {
                        if(isValid(r+rr,c+cc) && buttons[r+rr][c+cc].isClicked() == false)
                        {
                            buttons[r+rr][c+cc].mousePressed();//mouseSurround();
                        }
                    }
                }
            }
        }
    }

    public void draw () 
    {    
        if(marked)
            fill(50,50,255);
        else if( clicked && bombs.contains(this) ) 
            fill(255,0,0);
        else if(clicked)
            fill( 225 );
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

    public int countMarks(int row, int col)
    {
        int numMarks = 0;
        
        for(int rr = -1; rr < 2; rr++)
        {
            for(int cc = -1; cc < 2; cc++)
            {
                if(isValid(row+rr,col+cc) && buttons[row+rr][col+cc].isMarked())
                {
                    numMarks++;
                }
            }
        }

        return numMarks;
    }
}
